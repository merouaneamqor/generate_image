require 'net/http'
require 'json'

module GenerateImage
  class RequestFailed < StandardError; end

  class << self
    API_ENDPOINT = 'https://api.openai.com/v1/images/generations'
    IMAGE_MODEL_NAME = 'image-alpha-001'
    TEXT_MODEL_NAME = 'text-davinci-002'
    API_KEY = ENV['DALL_E_API_KEY']

    def generate_image(text, options = {})
      unless API_KEY
        raise StandardError, "API Key not set"
      end
      uri = URI(API_ENDPOINT)
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{API_KEY}"
      request.body = {
        model: options[:model] || IMAGE_MODEL_NAME,
        prompt: text,
        num_images: options[:num_images] || 1,
        size: options[:size] || '512x512',
        response_format: options[:response_format] || 'url',
        style: options[:style] || nil,
        scale: options[:scale] || 1,
        seed: options[:seed] || nil,
        quality: options[:quality] || 80,
        text_model: options[:text_model] || TEXT_MODEL_NAME,
        text_prompt: options[:text_prompt] || nil,
        text_length: options[:text_length] || nil
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
