# frozen_string_literal: true

require "json"
require "tempfile"

RSpec.describe GenerateImage::HTTP do
  let(:configuration) do
    c = GenerateImage::Configuration.new
    c.api_key = "sk-test"
    c.base_url = "https://api.openai.com"
    c.max_retries = 1
    c
  end

  let(:http) { described_class.new(configuration: configuration) }

  describe "#post_json" do
    it "posts JSON and returns parsed body" do
      stub_request(:post, "https://api.openai.com/v1/images/generations")
        .with(
          body: '{"prompt":"hi","model":"gpt-image-1"}',
          headers: { "Authorization" => "Bearer sk-test", "Content-Type" => "application/json" }
        )
        .to_return(status: 200, body: { data: [] }.to_json, headers: { "Content-Type" => "application/json" })

      result = http.post_json("/v1/images/generations", { prompt: "hi", model: "gpt-image-1" })
      expect(result["data"]).to eq([])
    end

    it "raises AuthenticationError on 401" do
      stub_request(:post, "https://api.openai.com/v1/x")
        .to_return(status: 401, body: { error: { message: "bad" } }.to_json)

      expect do
        http.post_json("/v1/x", {})
      end.to raise_error(GenerateImage::AuthenticationError, /bad/)
    end

    it "retries on 429 then succeeds" do
      stub_request(:post, "https://api.openai.com/v1/images/generations")
        .to_return({ status: 429, headers: { "Retry-After" => "0" } },
                   { status: 200, body: { ok: true }.to_json, headers: { "Content-Type" => "application/json" } })

      result = http.post_json("/v1/images/generations", { prompt: "x", model: "gpt-image-1" })
      expect(result["ok"]).to be true
    end
  end

  describe "#post_multipart" do
    it "sends multipart with file field" do
      stub_request(:post, "https://api.openai.com/v1/images/edits")
        .with { |req|
          req.body.include?('name="prompt"') &&
            req.body.include?('name="image"') &&
            req.headers["Content-Type"].start_with?("multipart/form-data; boundary=")
        }
        .to_return(status: 200, body: { data: [{ b64_json: "qqq" }] }.to_json)

      tmp = Tempfile.new(["img", ".png"])
      tmp.binmode
      tmp.write("\x89PNG\r\n\x1a\n")
      tmp.close

      result = http.post_multipart(
        "/v1/images/edits",
        { "model" => "gpt-image-1", "prompt" => "edit me", "n" => "1", "size" => "1024x1024" },
        { "image" => tmp.path }
      )
      expect(result["data"].first["b64_json"]).to eq("qqq")
    ensure
      tmp&.unlink
    end
  end
end
