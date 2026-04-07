# frozen_string_literal: true

RSpec.describe GenerateImage::Configuration do
  describe "#resolved_api_key" do
    it "prefers explicit api_key" do
      ENV["OPENAI_API_KEY"] = "openai"
      ENV["DALL_E_API_KEY"] = "dalle"
      c = described_class.new
      c.api_key = "explicit"
      expect(c.resolved_api_key).to eq("explicit")
    end

    it "falls back to OPENAI_API_KEY then DALL_E_API_KEY" do
      ENV["DALL_E_API_KEY"] = "dalle"
      expect(described_class.new.resolved_api_key).to eq("dalle")

      ENV["OPENAI_API_KEY"] = "openai"
      expect(described_class.new.resolved_api_key).to eq("openai")
    end
  end

  describe "defaults" do
    it "matches 2026-oriented defaults" do
      c = described_class.new
      expect(c.default_model).to eq("gpt-image-1")
      expect(c.base_url).to eq("https://api.openai.com")
      expect(c.default_size).to eq("1024x1024")
      expect(c.default_quality).to eq("auto")
      expect(c.default_output_format).to eq("png")
    end
  end
end
