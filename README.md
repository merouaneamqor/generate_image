# GenerateImage

Lightweight **Ruby** client for the **OpenAI Images API**: image generation (`POST /v1/images/generations`) and edits (`POST /v1/images/edits`). Uses only the standard library (`Net::HTTP`, `JSON`). **Ruby >= 3.1**.

> **Deprecation / sunset (OpenAI):** DALL·E 2 and DALL·E 3 are scheduled for **sunset on May 12, 2026**. Prefer **GPT Image** models (`gpt-image-1`, `gpt-image-1.5`, `gpt-image-1-mini`) for new integrations. This gem defaults to `gpt-image-1`.

## Installation

Add to your Gemfile:

```ruby
gem "generate_image", "~> 2.0"
```

Then:

```bash
bundle install
```

## Configuration

Set **`OPENAI_API_KEY`** (recommended). The legacy **`DALL_E_API_KEY`** is still read as a fallback if `OPENAI_API_KEY` is unset.

Optional global defaults:

```ruby
require "generate_image"

GenerateImage.configure do |c|
  c.api_key = ENV["OPENAI_API_KEY"]
  c.default_model = "gpt-image-1"
  c.base_url = "https://api.openai.com"
  c.default_size = "1024x1024"
  c.default_quality = "auto"
  c.default_output_format = "png"
  c.open_timeout = 30
  c.read_timeout = 120
  c.max_retries = 1 # extra attempts after HTTP 429, honors Retry-After
end
```

You can also pass an API key per client: `GenerateImage::Client.new("sk-...")`.

## Usage

### Generate (GPT Image)

```ruby
client = GenerateImage::Client.new

response = client.generate("A ruby gemstone on velvet, product photo")

response.b64        # first image base64 (typical for GPT Image)
response.url        # first HTTPS URL when API returns URLs
response.images     # => [{ b64_json: "..." }] or [{ url: "..." }], ...
response.usage      # token usage hash or nil
response.model      # model used
response.raw        # full parsed JSON Hash
```

Common options (passed as keyword args):

| Option | GPT Image | DALL·E 3 |
|--------|-----------|----------|
| `model` | `gpt-image-1`, `gpt-image-1.5`, `gpt-image-1-mini` | `dall-e-3` |
| `n` | 1–10 | 1 only |
| `size` | `auto`, `1024x1024`, `1536x1024`, `1024x1536` | `1024x1024`, `1792x1024`, `1024x1792` |
| `quality` | `auto`, `high`, `medium`, `low` | `standard`, `hd` |
| `output_format` | `png`, `jpeg`, `webp` | (API returns URLs by default; use `response_format`) |
| `background` | `transparent`, `opaque`, `auto` | — |
| `response_format` | `url`, `b64_json` if you need to force format | often `url` |

```ruby
client.generate(
  "Minimal logo",
  model: "gpt-image-1-mini",
  size: "1024x1024",
  quality: "high",
  output_format: "png",
  background: "transparent",
  n: 2
)
```

### Generate (DALL·E 3)

```ruby
client.generate(
  "Sunset over the Atlantic",
  model: "dall-e-3",
  size: "1792x1024",
  quality: "hd",
  response_format: "url"
)
```

### Edit / inpainting

Multipart request with at least **`image:`** (path string, `Pathname`, `IO`, or `StringIO`) and **`prompt:`**.

```ruby
client.edit(
  image: "input.png",
  prompt: "Add soft studio lighting",
  model: "gpt-image-1",
  size: "1024x1024",
  quality: "auto",
  mask: "mask.png" # optional
)
```

Additional GPT Image–oriented options: `output_format`, `background`, `input_fidelity` (`high` / `low`), `response_format`, `user`.

### Errors

| Exception | When |
|-----------|------|
| `GenerateImage::AuthenticationError` | 401 / missing API key |
| `GenerateImage::RateLimitError` | 429 (retried according to `max_retries` and `Retry-After`) |
| `GenerateImage::ApiError` | Other non-success HTTP responses (`#status_code`, `#body`) |
| `GenerateImage::ValidationError` | Invalid prompt, model/size/n combination, etc. |

`GenerateImage::RequestFailed` is an alias for `ApiError` for compatibility with rescues from v1.x.

## Backward compatibility (v1.x)

- `client.generate_image(text, options_hash)` still works but **prints a deprecation warning** and returns a legacy-shaped `Hash` (`:image_url` or `:image_base64`) via `Response#to_h`.
- Legacy keys: `num_images` → `n`, `response_format: "base64"` → `b64_json` for the API.

Prefer:

```ruby
response = client.generate("A cat")
response.url || response.b64
```

## Migration from 1.x

1. Bump Ruby to **3.1+** and gem to **~> 2.0**.
2. Set **`OPENAI_API_KEY`** (keep `DALL_E_API_KEY` temporarily if needed).
3. Replace `generate_image(...)` with `generate(...)` and read `Response` fields instead of only a Hash.
4. Update defaults mentally: model is **`gpt-image-1`**, size **`1024x1024`**, not DALL·E 2 `512x512` / `image-alpha-001`.
5. Plan for **DALL·E 2/3 sunset (May 12, 2026)** — move prompts to GPT Image models.

## Development

```bash
bundle install
bundle exec rspec
```

Interactive console:

```bash
bin/console
```

## Contributing

Issues and pull requests are welcome on the [GitHub repository](https://github.com/merouaneamqor/generate_image).

## License

MIT. See [LICENSE.txt](LICENSE.txt).
