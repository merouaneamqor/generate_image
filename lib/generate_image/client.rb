# frozen_string_literal: true

require "delegate"

module GenerateImage
  class Client
    DEPRECATE_GENERATE_IMAGE_MSG =
      "[DEPRECATION] GenerateImage::Client#generate_image is deprecated; use #generate instead."

    def initialize(api_key = nil)
      @api_key_override = api_key
    end

    def generate(prompt, **opts)
      raise ValidationError, "prompt must be a non-empty String" unless prompt.is_a?(String) && !prompt.strip.empty?

      model = (opts[:model] || configuration.default_model).to_s
      validate_generation_model!(model)

      body = build_generation_body(prompt, model, opts)
      parsed = http.post_json("/v1/images/generations", body)
      Response.new(parsed, model: model)
    end

    def edit(image:, prompt:, **opts)
      raise ValidationError, "prompt must be a non-empty String" unless prompt.is_a?(String) && !prompt.strip.empty?
      raise ValidationError, "image is required" if image.nil?

      model = (opts[:model] || configuration.default_model).to_s
      validate_edit_model!(model)

      fields = build_edit_fields(model, prompt, opts)
      files = { "image" => image }
      files["mask"] = opts[:mask] if opts[:mask]

      parsed = http.post_multipart("/v1/images/edits", fields, files)
      Response.new(parsed, model: model)
    end

    def generate_image(text, options = {})
      warn "#{DEPRECATE_GENERATE_IMAGE_MSG}\n"
      generate(text, **legacy_options_to_new(options)).to_h
    end

    private

    def configuration
      base = GenerateImage.configuration
      if @api_key_override && !@api_key_override.to_s.strip.empty?
        KeyOverride.new(base, @api_key_override)
      else
        base
      end
    end

    def http
      @http ||= HTTP.new(configuration: configuration)
    end

    def build_generation_body(prompt, model, opts)
      cfg = configuration
      n = (opts.key?(:n) ? opts[:n] : 1).to_i
      size = (opts[:size] || cfg.default_size).to_s

      validate_generation_n!(model, n)
      validate_generation_size!(model, size)

      body = {
        prompt: prompt,
        model: model,
        n: n,
        size: size
      }

      if Models.gpt_image?(model)
        body[:quality] = (opts[:quality] || cfg.default_quality).to_s
        of = opts[:output_format] || cfg.default_output_format
        body[:output_format] = of.to_s if of && !of.to_s.empty?
        body[:background] = opts[:background].to_s if opts[:background]
        body[:response_format] = opts[:response_format].to_s if opts[:response_format]
        body[:style] = opts[:style].to_s if opts[:style]
      elsif Models.dall_e_3?(model)
        body[:quality] = (opts[:quality] || "standard").to_s
        body[:response_format] = (opts[:response_format] || "url").to_s
        body[:style] = opts[:style].to_s if opts[:style]
      else
        body[:response_format] = opts[:response_format].to_s if opts[:response_format]
      end

      body[:user] = opts[:user].to_s if opts[:user]
      body.compact
    end

    def build_edit_fields(model, prompt, opts)
      cfg = configuration
      n = (opts.key?(:n) ? opts[:n] : 1).to_i
      size = (opts[:size] || cfg.default_size).to_s

      validate_generation_n!(model, n)
      validate_generation_size!(model, size)

      fields = {
        "model" => model,
        "prompt" => prompt,
        "n" => n.to_s,
        "size" => size
      }

      if Models.gpt_image?(model)
        fields["quality"] = (opts[:quality] || cfg.default_quality).to_s
        of = opts[:output_format] || cfg.default_output_format
        fields["output_format"] = of.to_s if of && !of.to_s.empty?
        fields["background"] = opts[:background].to_s if opts[:background]
        fields["input_fidelity"] = opts[:input_fidelity].to_s if opts[:input_fidelity]
        fields["response_format"] = opts[:response_format].to_s if opts[:response_format]
      elsif Models.dall_e_3?(model)
        fields["quality"] = (opts[:quality] || "standard").to_s
        fields["response_format"] = (opts[:response_format] || "url").to_s
      elsif opts[:response_format]
        fields["response_format"] = opts[:response_format].to_s
      end

      fields["user"] = opts[:user].to_s if opts[:user]
      fields.compact
    end

    def validate_generation_model!(model)
      return if Models::ALL.include?(model)

      raise ValidationError, "Unknown model #{model.inspect}. Expected one of: #{Models::ALL.join(", ")}"
    end

    def validate_edit_model!(model)
      # Edits are supported for gpt-image and dall-e-2 historically; dall-e-3 may differ — allow gpt + dall-e-2 + dall-e-3 per API
      return if Models.gpt_image?(model) || model == Models::DALLE2 || model == Models::DALLE3

      raise ValidationError,
            "Unsupported edit model #{model.inspect}. Use a GPT Image model, #{Models::DALLE2}, or #{Models::DALLE3}."
    end

    def validate_generation_n!(model, n)
      raise ValidationError, "n must be between 1 and 10" unless n >= 1 && n <= 10

      return unless Models.dall_e_3?(model)

      raise ValidationError, "n must be 1 for #{model}" if n != 1
    end

    def validate_generation_size!(model, size)
      valid =
        if Models.gpt_image?(model)
          Models::GPT_IMAGE_SIZES.include?(size)
        elsif Models.dall_e_3?(model)
          Models::DALLE3_SIZES.include?(size)
        else
          Models::DALLE2_SIZES.include?(size)
        end

      return if valid

      allowed =
        if Models.gpt_image?(model)
          Models::GPT_IMAGE_SIZES
        elsif Models.dall_e_3?(model)
          Models::DALLE3_SIZES
        else
          Models::DALLE2_SIZES
        end

      raise ValidationError, "Invalid size #{size.inspect} for #{model}. Allowed: #{allowed.join(", ")}"
    end

    def legacy_options_to_new(options)
      h = options.transform_keys { |k| k.to_sym }
      if h.key?(:num_images)
        h[:n] = h.delete(:num_images)
      end
      if h.key?(:response_format)
        case h[:response_format].to_s
        when "base64", "b64"
          h[:response_format] = "b64_json"
        end
      end
      h
    end

    class KeyOverride < SimpleDelegator
      def initialize(base, api_key)
        super(base)
        @override_key = api_key
      end

      def resolved_api_key
        s = @override_key.to_s
        return s unless s.strip.empty?

        __getobj__.resolved_api_key
      end
    end
  end
end
