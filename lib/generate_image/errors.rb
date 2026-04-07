# frozen_string_literal: true

module GenerateImage
  class Error < StandardError; end

  class AuthenticationError < Error; end

  class RateLimitError < Error
    attr_reader :retry_after

    def initialize(message = nil, retry_after: 1)
      super(message)
      @retry_after = retry_after
    end
  end

  class ApiError < Error
    attr_reader :status_code, :body

    def initialize(message = nil, status_code: nil, body: nil)
      super(message)
      @status_code = status_code
      @body = body
    end
  end

  class ValidationError < Error; end

  # @deprecated Use {ApiError} instead. Kept for v1.x rescue compatibility.
  RequestFailed = ApiError
end
