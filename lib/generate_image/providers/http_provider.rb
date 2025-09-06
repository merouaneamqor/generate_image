require 'net/http'
require 'json'
require 'uri'

module GenerateImage
  # Generic HTTP provider for any REST API-based image generation service
  class HTTPProvider < Provider
    def initialize(api_key = nil, base_url = nil)
      super(api_key)
      @base_url = base_url
    end

    def generate_image(prompt, options = {})
      validate_prompt(prompt)
      return { error: 'HTTP provider not configured' } unless configured?

      endpoint = build_endpoint(options)
      headers = build_headers(options)
      body = build_request_body(prompt, options)

      begin
        uri = URI(endpoint)
        request = Net::HTTP::Post.new(uri)
        headers.each { |key, value| request[key] = value }
        request.body = body.to_json if body

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        process_response(response, options)
      rescue StandardError => e
        raise RequestFailed, "HTTP provider error: #{e.message}"
      end
    end

    def available_models
      # Override in subclasses
      []
    end

    def supported_sizes
      # Override in subclasses
      []
    end

    protected

    # Override these methods in subclasses for custom behavior

    def build_endpoint(options)
      raise NotImplementedError, 'Subclasses must implement build_endpoint'
    end

    def build_headers(_options)
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@api_key}"
      }
    end

    def build_request_body(prompt, options)
      {
        prompt: prompt,
        model: options[:model],
        size: options[:size],
        num_images: options[:num_images] || 1
      }
    end

    def process_response(response, _options)
      case response.code.to_i
      when 200
        data = JSON.parse(response.body)

        # Try to extract image data from common response formats
        if data['image_url']
          { image_url: data['image_url'] }
        elsif data['image_base64'] || data['base64']
          { image_base64: data['image_base64'] || data['base64'] }
        elsif data['data'].is_a?(Array) && data['data'].first
          image_data = data['data'].first
          if image_data['url']
            { image_url: image_data['url'] }
          elsif image_data['b64_json'] || image_data['base64']
            { image_base64: image_data['b64_json'] || image_data['base64'] }
          else
            raise RequestFailed, 'Unable to extract image data from response'
          end
        else
          raise RequestFailed, 'No image data found in response'
        end
      else
        error_message = begin
          JSON.parse(response.body)['error'] || JSON.parse(response.body)['message']
        rescue StandardError
          response.body
        end
        raise RequestFailed, "HTTP provider error: #{response.code} - #{error_message}"
      end
    end
  end

  # Example: Custom provider using the HTTP provider template
  class CustomAPIProvider < HTTPProvider
    def initialize(api_key = nil)
      super(api_key, ENV['CUSTOM_API_BASE_URL'] || 'https://api.example.com')
    end

    def build_endpoint(_options)
      "#{@base_url}/v1/images/generate"
    end

    def build_request_body(prompt, options)
      {
        prompt: prompt,
        model: options[:model] || 'default-model',
        width: extract_width(options[:size] || '512x512'),
        height: extract_height(options[:size] || '512x512'),
        num_images: options[:num_images] || 1,
        format: options[:response_format] || 'url'
      }
    end

    def available_models
      %w[default-model premium-model fast-model]
    end

    def supported_sizes
      %w[256x256 512x512 768x768 1024x1024]
    end

    private

    def extract_width(size)
      size.split('x')[0].to_i
    end

    def extract_height(size)
      size.split('x')[1].to_i
    end
  end
end
