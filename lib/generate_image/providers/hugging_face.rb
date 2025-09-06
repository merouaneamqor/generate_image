require 'net/http'
require 'json'
require 'uri'

module GenerateImage
  # Hugging Face provider for image generation
  class HuggingFaceProvider < Provider
    BASE_URL = 'https://api-inference.huggingface.co'.freeze

    def initialize(api_key = nil)
      super(api_key || ENV.fetch('HUGGINGFACE_API_KEY', nil))
      @base_url = ENV['HUGGINGFACE_BASE_URL'] || BASE_URL
    end

    def generate_image(prompt, options = {})
      validate_prompt(prompt)
      return { error: 'Hugging Face provider not configured' } unless configured?

      model = options[:model] || 'CompVis/stable-diffusion-v1-4'
      endpoint = "#{@base_url}/models/#{model}"

      request_body = {
        inputs: prompt,
        parameters: {
          num_inference_steps: options[:steps] || 20,
          guidance_scale: options[:guidance_scale] || 7.5,
          width: extract_width(options[:size] || '512x512'),
          height: extract_height(options[:size] || '512x512')
        }
      }

      # Add negative prompt if provided
      request_body[:parameters][:negative_prompt] = options[:negative_prompt] if options[:negative_prompt]

      begin
        uri = URI(endpoint)
        request = Net::HTTP::Post.new(uri)
        request['Content-Type'] = 'application/json'
        request['Authorization'] = "Bearer #{@api_key}"
        request.body = request_body.to_json

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        process_response(response)
      rescue StandardError => e
        raise RequestFailed, "Hugging Face API error: #{e.message}"
      end
    end

    def available_models
      ['CompVis/stable-diffusion-v1-4', 'runwayml/stable-diffusion-v1-5',
       'stabilityai/stable-diffusion-2-1', 'stabilityai/stable-diffusion-xl-base-1.0',
       'prompthero/openjourney', 'wavymulder/Analog-Diffusion']
    end

    def supported_sizes
      %w[256x256 512x512 768x768 1024x1024]
    end

    private

    def extract_height(size)
      size.split('x')[1].to_i
    end

    def extract_width(size)
      size.split('x')[0].to_i
    end

    def process_response(response)
      case response.code.to_i
      when 200
        # Hugging Face returns binary image data
        { image_base64: Base64.strict_encode64(response.body) }
      when 400
        error_data = begin
          JSON.parse(response.body)
        rescue StandardError
          {}
        end
        raise RequestFailed, "Hugging Face validation error: #{error_data['error'] || response.body}"
      when 401
        raise RequestFailed, 'Hugging Face authentication failed'
      when 403
        raise RequestFailed, 'Hugging Face access forbidden'
      when 429
        raise RequestFailed, 'Hugging Face rate limit exceeded'
      when 503
        raise RequestFailed, 'Hugging Face model is loading, please retry'
      else
        raise RequestFailed, "Hugging Face API error: #{response.code} - #{response.body}"
      end
    end
  end
end
