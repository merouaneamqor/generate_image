require 'net/http'
require 'json'

module GenerateImage
  class << self
    API_ENDPOINT = 'https://api.openai.com/v1/images/generations'
    MODEL_NAME = 'image-alpha-001'

    def generate_image(text)
      api_key = ENV['DALL_E_API_KEY']
      unless api_key
        raise StandardError, "API Key not set"
      end

      uri = URI(API_ENDPOINT)
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{api_key}"
      request.body = {
        model: MODEL_NAME,
        prompt: text,
        num_images: 1
      }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      if response.code == '200'
        image_url = JSON.parse(response.body)['data'][0]['url']
        return { image_url: image_url }
      else
        message = "Failed to generate image. Response code: #{response.code}. Response body: #{response.body}"
        Rails.logger.error(message) if defined?(Rails)
        return { error: message }, 500
      end
    end
  end
end

