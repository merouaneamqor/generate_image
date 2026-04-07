# frozen_string_literal: true

module GenerateImage
  class Response
    attr_reader :raw, :model

    def initialize(parsed_json, model: nil)
      @raw = parsed_json
      @model = model
    end

    def data_items
      Array(raw["data"])
    end

    def images
      data_items.map do |item|
        if item["url"]
          { url: item["url"] }
        elsif item["b64_json"]
          { b64_json: item["b64_json"] }
        else
          {}
        end
      end
    end

    def url
      data_items.find { |d| d["url"] }&.fetch("url", nil)
    end

    def b64
      data_items.find { |d| d["b64_json"] }&.fetch("b64_json", nil)
    end

    def usage
      raw["usage"]
    end

    def created
      raw["created"]
    end

    def to_h
      if url
        { image_url: url }
      elsif b64
        { image_base64: b64 }
      else
        {}
      end
    end
  end
end
