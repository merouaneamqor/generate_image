require 'net/http'
require 'json'

module GenerateImage
  class << self
    def generate_image(text)
      api_key = ENV['DALL_E_API_KEY']

      uri = URI('https://api.openai.com/v1/images/generations')
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{api_key}"
      request.body = {
        model: 'image-alpha-001',
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
        return { error: "Failed to generate image" }, 500
      end
    end
  end
end

