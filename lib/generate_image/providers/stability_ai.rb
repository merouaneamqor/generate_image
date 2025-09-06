require 'net/http'
require 'json'
require 'uri'

module GenerateImage
  # Stability AI provider for image generation
  class StabilityAIProvider < Provider
    BASE_URL = 'https://api.stability.ai'.freeze

    def initialize(api_key = nil)
      super(api_key || ENV.fetch('STABILITY_API_KEY', nil))
      @base_url = ENV['STABILITY_BASE_URL'] || BASE_URL
    end

    def generate_image(prompt, options = {})
      validate_prompt(prompt)
      return { error: 'Stability AI provider not configured' } unless configured?

      model = options[:model] || 'stable-diffusion-v1-5'
      endpoint = "#{@base_url}/v1/generation/#{model}/text-to-image"

      request_body = {
        text_prompts: [{ text: prompt }],
        cfg_scale: options[:cfg_scale] || 7,
        clip_guidance_preset: options[:clip_guidance_preset] || 'FAST_BLUE',
        height: extract_height(options[:size] || '512x512'),
        width: extract_width(options[:size] || '512x512'),
        samples: options[:num_images] || 1,
        steps: options[:steps] || 20
      }

      # Add style preset if provided
      request_body[:style_preset] = options[:style_preset] if options[:style_preset]

      begin
        uri = URI(endpoint)
        request = Net::HTTP::Post.new(uri)
        request['Content-Type'] = 'application/json'
        request['Accept'] = 'application/json'
        request['Authorization'] = "Bearer #{@api_key}"
        request.body = request_body.to_json

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        process_response(response)
      rescue StandardError => e
        raise RequestFailed, "Stability AI API error: #{e.message}"
      end
    end

    def available_models
      ['stable-diffusion-v1', 'stable-diffusion-v1-5', 'stable-diffusion-512-v2-0',
       'stable-diffusion-768-v2-0', 'stable-diffusion-512-v2-1', 'stable-diffusion-768-v2-1',
       'stable-diffusion-xl-beta-v2-2-2', 'stable-diffusion-xl-1024-v0-9',
       'stable-diffusion-xl-1024-v1-0']
    end

    def supported_sizes
      %w[256x256 512x512 768x768 1024x1024 1536x1536]
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
        data = JSON.parse(response.body)
        raise RequestFailed, 'No artifacts in Stability AI response' unless data['artifacts']&.length&.positive?

        artifact = data['artifacts'].first
        raise RequestFailed, 'No base64 data in Stability AI response' unless artifact['base64']

        { image_base64: artifact['base64'] }

      when 400
        error_data = JSON.parse(response.body)
        raise RequestFailed, "Stability AI validation error: #{error_data['message']}"
      when 401
        raise RequestFailed, 'Stability AI authentication failed'
      when 403
        raise RequestFailed, 'Stability AI access forbidden'
      when 429
        raise RequestFailed, 'Stability AI rate limit exceeded'
      else
        raise RequestFailed, "Stability AI API error: #{response.code} - #{response.body}"
      end
    end
  end
end
