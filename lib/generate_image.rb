# frozen_string_literal: true

require_relative "generate_image/version"
require_relative "generate_image/errors"
require_relative "generate_image/configuration"
require_relative "generate_image/models"
require_relative "generate_image/response"
require_relative "generate_image/http"
require_relative "generate_image/client"

module GenerateImage
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
