# frozen_string_literal: true

module GenerateImage
  class Configuration
    attr_accessor :api_key, :default_model, :base_url, :default_size, :default_quality,
                  :default_output_format, :open_timeout, :read_timeout, :max_retries

    def initialize
      @api_key = nil
      @default_model = "gpt-image-1"
      @base_url = "https://api.openai.com"
      @default_size = "1024x1024"
      @default_quality = "auto"
      @default_output_format = "png"
      @open_timeout = 30
      @read_timeout = 120
      @max_retries = 1
    end

    def resolved_api_key
      [api_key, ENV["OPENAI_API_KEY"], ENV["DALL_E_API_KEY"]]
        .compact
        .map(&:to_s)
        .find { |s| !s.strip.empty? }
    end
  end
end
