# frozen_string_literal: true

RSpec.describe GenerateImage::Response do
  describe "#url, #b64, #images, #usage" do
    it "parses URL responses" do
      raw = {
        "created" => 1,
        "data" => [{ "url" => "https://example.com/a.png" }]
      }
      r = described_class.new(raw, model: "dall-e-3")
      expect(r.url).to eq("https://example.com/a.png")
      expect(r.b64).to be_nil
      expect(r.images).to eq([{ url: "https://example.com/a.png" }])
      expect(r.usage).to be_nil
      expect(r.model).to eq("dall-e-3")
    end

    it "parses base64 responses" do
      raw = { "data" => [{ "b64_json" => "abc" }] }
      r = described_class.new(raw)
      expect(r.b64).to eq("abc")
      expect(r.url).to be_nil
      expect(r.images).to eq([{ b64_json: "abc" }])
    end

    it "exposes usage when present" do
      raw = {
        "data" => [{ "b64_json" => "x" }],
        "usage" => { "input_tokens" => 1, "output_tokens" => 2, "total_tokens" => 3 }
      }
      r = described_class.new(raw)
      expect(r.usage["total_tokens"]).to eq(3)
    end
  end

  describe "#to_h" do
    it "returns legacy-compatible hash" do
      raw = { "data" => [{ "url" => "https://x.test" }] }
      expect(described_class.new(raw).to_h).to eq({ image_url: "https://x.test" })
    end
  end
end
