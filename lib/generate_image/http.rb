# frozen_string_literal: true

require "json"
require "net/http"
require "securerandom"
require "stringio"
require "uri"

module GenerateImage
  class HTTP
    def initialize(configuration:)
      @configuration = configuration
    end

    def post_json(path, body_hash)
      uri = build_uri(path)
      body = JSON.generate(body_hash)

      with_retries do
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{api_key}"
        request["Content-Type"] = "application/json"
        request.body = body
        perform(uri, request)
      end
    end

    def post_multipart(path, fields, files)
      uri = build_uri(path)
      boundary = "----RubyGenerateImage#{SecureRandom.hex(16)}"
      body = build_multipart_body(boundary, fields, files)

      with_retries do
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{api_key}"
        request["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
        request.body = body
        perform(uri, request)
      end
    end

    private

    attr_reader :configuration

    def api_key
      key = configuration.resolved_api_key
      raise AuthenticationError, "Missing API key. Set OPENAI_API_KEY or configure api_key." if key.nil? || key.strip.empty?

      key
    end

    def build_uri(path)
      base = configuration.base_url.to_s.chomp("/")
      URI.join("#{base}/", path.delete_prefix("/"))
    end

    def perform(uri, request)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = configuration.open_timeout
      http.read_timeout = configuration.read_timeout

      response = http.request(request)
      handle_response(response)
    end

    def handle_response(response)
      case response.code.to_i
      when 200, 201
        parse_json_body(response.body)
      when 401
        raise AuthenticationError, error_message_from(response)
      when 429
        raise RateLimitError.new(
          error_message_from(response),
          retry_after: parse_retry_after(response["Retry-After"])
        )
      else
        raise ApiError.new(error_message_from(response), status_code: response.code.to_i, body: response.body)
      end
    end

    def parse_json_body(body)
      return {} if body.nil? || body.empty?

      JSON.parse(body)
    rescue JSON::ParserError
      raise ApiError.new("Invalid JSON response", body: body)
    end

    def error_message_from(response)
      parsed = safe_parse_json(response.body)
      err = parsed["error"]
      if err.is_a?(Hash)
        err["message"] || err.inspect
      elsif err.is_a?(String)
        err
      else
        "HTTP #{response.code}: #{response.message}"
      end
    rescue StandardError
      "HTTP #{response.code}: #{response.message}"
    end

    def safe_parse_json(body)
      return {} if body.nil? || body.empty?

      JSON.parse(body)
    rescue JSON::ParserError, TypeError
      {}
    end

    def parse_retry_after(value)
      s = value.to_s.strip
      return 1 if s.empty?

      if s.match?(/^\d+$/)
        s.to_i.clamp(1, 120)
      else
        1
      end
    end

    def with_retries
      attempts = 0
      max = [configuration.max_retries.to_i, 0].max

      begin
        yield
      rescue RateLimitError => e
        attempts += 1
        raise e if attempts > max

        sleep(e.retry_after.to_f.positive? ? e.retry_after : 1)
        retry
      end
    end

    def build_multipart_body(boundary, fields, files)
      io = StringIO.new
      crlf = "\r\n"

      fields.each do |name, value|
        next if value.nil?

        io << "--#{boundary}#{crlf}"
        io << "Content-Disposition: form-data; name=\"#{escape_name(name)}\"#{crlf}#{crlf}"
        io << value.to_s
        io << crlf
      end

      files.each do |name, file_spec|
        filename, content, content_type = normalize_file_spec(name, file_spec)
        io << "--#{boundary}#{crlf}"
        io << "Content-Disposition: form-data; name=\"#{escape_name(name)}\"; filename=\"#{escape_filename(filename)}\"#{crlf}"
        io << "Content-Type: #{content_type}#{crlf}#{crlf}"
        io << content
        io << crlf
      end

      io << "--#{boundary}--#{crlf}"
      io.string
    end

    def escape_name(name)
      name.to_s.gsub(/["\r\n]/, "")
    end

    def escape_filename(name)
      name.to_s.gsub(/["\r\n]/, "")
    end

    def normalize_file_spec(name, spec)
      case spec
      when String
        path = spec
        [File.basename(path), File.binread(path), mime_for_path(path)]
      when Pathname
        path = spec.to_s
        [File.basename(path), File.binread(path), mime_for_path(path)]
      when Hash
        filename = spec[:filename] || spec["filename"] || "image.png"
        io = spec[:io] || spec["io"]
        content_type = spec[:content_type] || spec["content_type"] || "application/octet-stream"
        content =
          if io.respond_to?(:read)
            io.rewind if io.respond_to?(:rewind)
            io.read
          else
            spec[:data] || spec["data"] || ""
          end
        [filename, content, content_type]
      else
        if spec.respond_to?(:read)
          filename = spec.respond_to?(:path) && spec.path ? File.basename(spec.path) : "#{name}.png"
          spec.rewind if spec.respond_to?(:rewind)
          [filename, spec.read, "application/octet-stream"]
        else
          raise ValidationError, "Unsupported file payload for #{name}"
        end
      end
    end

    def mime_for_path(path)
      case File.extname(path).downcase
      when ".png" then "image/png"
      when ".jpg", ".jpeg" then "image/jpeg"
      when ".webp" then "image/webp"
      when ".gif" then "image/gif"
      else "application/octet-stream"
      end
    end
  end
end
