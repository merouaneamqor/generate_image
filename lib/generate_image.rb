require 'net/http'

module GenerateImage
  class RequestFailed < StandardError
    def initialize(message = "Request failed")
      super(message)
    end
  end

  class MissingApiKey < RequestFailed
    def initialize(message = "API key not set")
      super(message)
    end
  end

  class << self
    API_ENDPOINT = 'https://api.openai.com/v1/images/generations'
    API_KEY = ENV['DALL_E_API_KEY']
    DEFAULT_OPTIONS = {
      model: 'image-alpha-001',
      num_images: 1,
      size: '1024x1024',
      response_format: 'url',
      style: nil,
      scale: 1,
      seed: nil,
      quality: 100,
      text_model: 'text-davinci-002',
      text_prompt: nil,
      text_length: nil
    }

    def generate_image(text, options = {})
      options = DEFAULT_OPTIONS.merge(options)
      raise MissingApiKey if API_KEY.nil?

      uri = URI(API_ENDPOINT)
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{API_KEY}"
      request.body = {
        model: options[:model],
        prompt: text,
        num_images: options[:num_images],
        size: options[:size],
        response_format: options[:response_format],
        style: options[:style],
        scale: options[:scale],
        seed: options[:seed],
        quality: options[:quality],
        text_model: options[:text_model],
        text_prompt: options[:text_prompt],
        text_length: options[:text_length]
      }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      if response.code == '200'
        if options[:response_format] == 'base64'
          image_base64 = JSON.parse(response.body)['data'][0]['base64']
          { image_base64: image_base64 }
        else
          image_url = JSON.parse(response.body)['data'][0]['url']
          { image_url: image_url }
        end
      else
        raise RequestFailed.new("Failed to generate image. Response code: #{response.code}. Response body: #{response.body}")
      end
    end
  end
end
