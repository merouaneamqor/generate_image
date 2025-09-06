require 'openai'

module GenerateImage
  # Abstract base class for image generation providers
  class Provider
    attr_reader :name, :api_key

    def initialize(api_key = nil)
      @api_key = api_key
      @name = self.class.name.split('::').last.downcase
    end

    # Generate an image with the given prompt and options
    # @param prompt [String] The text prompt for image generation
    # @param options [Hash] Additional options for image generation
    # @return [Hash] Response containing :image_url or :image_base64
    def generate_image(prompt, options = {})
      raise NotImplementedError, "Subclasses must implement generate_image"
    end

    # Check if this provider is properly configured
    # @return [Boolean]
    def configured?
      !@api_key.nil? && !@api_key.empty?
    end

    # Get available models for this provider
    # @return [Array<String>]
    def available_models
      []
    end

    # Get supported sizes for this provider
    # @return [Array<String>]
    def supported_sizes
      []
    end

    protected

    def validate_prompt(prompt)
      unless prompt.is_a?(String) && !prompt.strip.empty?
        raise ArgumentError, "Prompt must be a non-empty string"
      end
    end
  end

  # OpenAI DALL-E provider
  class OpenAIProvider < Provider
    def initialize(api_key = nil)
      super(api_key || ENV['OPENAI_API_KEY'] || ENV['DALL_E_API_KEY'])
      @client = OpenAI::Client.new(access_token: @api_key) if configured?
    end

    def generate_image(prompt, options = {})
      validate_prompt(prompt)
      return { error: "OpenAI provider not configured" } unless configured?

      params = build_parameters(prompt, options)

      begin
        response = @client.images.generate(parameters: params)
        process_response(response, options)
      rescue OpenAI::Error => e
        raise RequestFailed, "OpenAI API error: #{e.message}"
      rescue => e
        raise RequestFailed, "Unexpected error: #{e.message}"
      end
    end

    def available_models
      ['dall-e-2', 'dall-e-3', 'gpt-image-1']
    end

    def supported_sizes
      {
        'dall-e-2' => ['256x256', '512x512', '1024x1024'],
        'dall-e-3' => ['1024x1024', '1792x1024', '1024x1792'],
        'gpt-image-1' => ['1024x1024', '1536x1024', '1024x1536', 'auto']
      }
    end

    private

    def build_parameters(prompt, options)
      params = {
        prompt: prompt,
        model: options[:model] || 'dall-e-2',
        n: options[:num_images] || 1,
        size: options[:size] || '1024x1024',
        response_format: options[:response_format] || 'url'
      }

      # Add optional parameters if provided
      params[:quality] = options[:quality] if options[:quality]
      params[:style] = options[:style] if options[:style]
      params[:user] = options[:user] if options[:user]

      params
    end

    def process_response(response, options)
      if response.data && response.data.length > 0
        image = response.data.first
        if options[:response_format] == 'b64_json' || options[:response_format] == 'base64'
          if image.b64_json
            { image_base64: image.b64_json }
          else
            raise RequestFailed, "Base64 format requested but not available in response"
          end
        else
          if image.url
            { image_url: image.url }
          else
            raise RequestFailed, "URL format requested but not available in response"
          end
        end
      else
        raise RequestFailed, "No image data received in response"
      end
    end
  end
end
