# frozen_string_literal: true

require "json"
require "tempfile"

RSpec.describe GenerateImage::Client do
  let(:client) { described_class.new("sk-test") }

  describe "#generate" do
    it "calls generations with GPT Image defaults" do
      stub_request(:post, "https://api.openai.com/v1/images/generations")
        .with do |req|
          b = JSON.parse(req.body)
          b["prompt"] == "a ruby gemstone" &&
            b["model"] == "gpt-image-1" &&
            b["size"] == "1024x1024" &&
            b["quality"] == "auto" &&
            b["output_format"] == "png"
        end
        .to_return(status: 200, body: {
          data: [{ b64_json: "AAA" }],
          usage: { total_tokens: 10 }
        }.to_json)

      res = client.generate("a ruby gemstone")
      expect(res.b64).to eq("AAA")
      expect(res.usage["total_tokens"]).to eq(10)
    end

    it "maps DALL-E 3 params" do
      stub_request(:post, "https://api.openai.com/v1/images/generations")
        .with do |req|
          b = JSON.parse(req.body)
          b["model"] == "dall-e-3" && b["quality"] == "hd" && b["response_format"] == "url"
        end
        .to_return(status: 200, body: { data: [{ url: "https://cdn.example/x.png" }] }.to_json)

      res = client.generate("sunset", model: "dall-e-3", quality: "hd", size: "1792x1024")
      expect(res.url).to eq("https://cdn.example/x.png")
    end

    it "rejects invalid size for model" do
      expect do
        client.generate("x", model: "dall-e-3", size: "1024x1536")
      end.to raise_error(GenerateImage::ValidationError, /Invalid size/)
    end

    it "rejects n > 1 for dall-e-3" do
      expect do
        client.generate("x", model: "dall-e-3", n: 2)
      end.to raise_error(GenerateImage::ValidationError, /n must be 1/)
    end
  end

  describe "#edit" do
    it "posts multipart to edits" do
      stub_request(:post, "https://api.openai.com/v1/images/edits")
        .with { |req| req.body.include?("edit mask") && req.body.include?('name="image"') }
        .to_return(status: 200, body: { data: [{ b64_json: "EDIT" }] }.to_json)

      tmp = Tempfile.new(["in", ".png"])
      tmp.binmode
      tmp.write("fakepng")
      tmp.close

      res = client.edit(image: tmp.path, prompt: "edit mask", model: "gpt-image-1")
      expect(res.b64).to eq("EDIT")
    ensure
      tmp&.unlink
    end
  end

  describe "#generate_image (deprecated)" do
    it "delegates to #generate and returns legacy hash" do
      stub_request(:post, "https://api.openai.com/v1/images/generations")
        .to_return(status: 200, body: { data: [{ url: "https://legacy" }] }.to_json)

      expect do
        h = client.generate_image("old api", { response_format: "url" })
        expect(h).to eq({ image_url: "https://legacy" })
      end.to output(/DEPRECATION/).to_stderr
    end

    it "maps num_images and base64 response_format" do
      stub_request(:post, "https://api.openai.com/v1/images/generations")
        .with do |req|
          JSON.parse(req.body)["n"] == 2 && JSON.parse(req.body)["response_format"] == "b64_json"
        end
        .to_return(status: 200, body: { data: [{ b64_json: "BBB" }] }.to_json)

      expect do
        h = client.generate_image("x", num_images: 2, response_format: "base64")
        expect(h).to eq({ image_base64: "BBB" })
      end.to output(/DEPRECATION/).to_stderr
    end
  end

  describe "env key resolution" do
    it "uses DALL_E_API_KEY when OPENAI_API_KEY unset" do
      ENV["DALL_E_API_KEY"] = "from-dalle"
      c = described_class.new
      stub_request(:post, "https://api.openai.com/v1/images/generations")
        .with(headers: { "Authorization" => "Bearer from-dalle" })
        .to_return(status: 200, body: { data: [{ url: "https://u" }] }.to_json)

      expect(c.generate("p").url).to eq("https://u")
    end
  end
end
