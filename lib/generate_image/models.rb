# frozen_string_literal: true

module GenerateImage
  module Models
    GPT_IMAGE = %w[gpt-image-1 gpt-image-1.5 gpt-image-1-mini].freeze
    DALLE3 = "dall-e-3"
    DALLE2 = "dall-e-2"

    ALL = (GPT_IMAGE + [DALLE3, DALLE2]).freeze

    GPT_IMAGE_SIZES = %w[auto 1024x1024 1536x1024 1024x1536].freeze
    DALLE3_SIZES = %w[1024x1024 1792x1024 1024x1792].freeze
    DALLE2_SIZES = %w[256x256 512x512 1024x1024].freeze

    GPT_IMAGE_QUALITIES = %w[auto high medium low].freeze
    DALLE3_QUALITIES = %w[standard hd].freeze

    OUTPUT_FORMATS = %w[png jpeg webp].freeze

    module_function

    def gpt_image?(model)
      GPT_IMAGE.include?(model.to_s)
    end

    def dall_e_3?(model)
      model.to_s == DALLE3
    end
  end
end
