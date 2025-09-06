require_relative 'generate_image/providers'

module GenerateImage
  class RequestFailed < StandardError; end

  # Configuration class for managing providers
  class Configuration
    attr_accessor :default_provider, :providers

    def initialize
      @providers = {}
      @default_provider = :openai
      register_builtin_providers
    end

    def register_provider(name, provider_class, api_key = nil)
      @providers[name.to_sym] = provider_class.new(api_key)
    end

    def get_provider(name = nil)
      provider_name = name || @default_provider
      @providers[provider_name.to_sym] || raise(ArgumentError, "Provider '#{provider_name}' not found")
    end

    def set_default_provider(name)
      raise ArgumentError, "Provider '#{name}' not registered" unless @providers.key?(name.to_sym)

      @default_provider = name.to_sym
    end

    private

    def register_builtin_providers
      register_provider(:openai, OpenAIProvider)
      register_provider(:stability_ai, StabilityAIProvider)
      register_provider(:hugging_face, HuggingFaceProvider)
      register_provider(:custom_api, CustomAPIProvider)
    end
  end

  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
      configuration
    end

    # Convenience method for backward compatibility
    def generate_image(text, options = {})
      config = configuration || Configuration.new
      provider_name = options.delete(:provider)
      provider = config.get_provider(provider_name)
      provider.generate_image(text, options)
    end
  end

  class Client
    attr_reader :provider

    def initialize(provider_name = nil, api_key = nil)
      config = GenerateImage.configuration || GenerateImage::Configuration.new
      @provider = config.get_provider(provider_name)

      # Override API key if provided
      return unless api_key && @provider.respond_to?(:api_key=)

      @provider.instance_variable_set(:@api_key, api_key)
    end

    def generate_image(text, options = {})
      @provider.generate_image(text, options)
    end

    # Provider information methods
    def available_models
      @provider.available_models
    end

    def supported_sizes
      @provider.supported_sizes
    end

    def provider_name
      @provider.name
    end
  end
end
