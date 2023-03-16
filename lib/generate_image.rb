require 'net/http'
require 'json'

module GenerateImage
  class RequestFailed < StandardError; end

  class Client
    API_ENDPOINT = 'https://api.openai.com/v1/images/generations'

    def initialize(api_key)
      @api_key = api_key
    end

    def generate_image(text, options = {})
      unless @api_key
        raise StandardError, "API Key not set"
      end
      uri = URI(API_ENDPOINT)
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{API_KEY}"
      request.body = {
        prompt: text,
        n: options[:num_images] || 1,
        size: options[:size] || '512x512',
        response_format: options[:response_format] || 'url',
      }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      if response.code == '200'
        if options[:response_format] == 'base64'
          image_base64 = JSON.parse(response.body)['data'][0]['base64']
          return { image_base64: image_base64 }
        else
          image_url = JSON.parse(response.body)['data'][0]['url']
          return { image_url: image_url }
        end
      else
        raise RequestFailed, "Failed to generate image. Response code: #{response.code}. Response body: #{response.body}"
      end
    end
  end
end
