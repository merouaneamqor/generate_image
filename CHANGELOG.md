# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-04-07

### Added

- `GenerateImage.configure` for global defaults (`api_key`, `default_model`, `base_url`, `default_size`, `default_quality`, `default_output_format`, timeouts, `max_retries`).
- `GenerateImage::Client#generate` — `POST /v1/images/generations` with GPT Image models (`gpt-image-1`, `gpt-image-1.5`, `gpt-image-1-mini`) and DALL·E 2/3.
- `GenerateImage::Client#edit` — `POST /v1/images/edits` with multipart uploads (`image`, optional `mask`).
- `GenerateImage::Response` with `#url`, `#b64`, `#images`, `#usage`, `#model`, `#raw`, `#to_h` (legacy-shaped hash).
- Error types: `AuthenticationError`, `RateLimitError`, `ApiError`, `ValidationError`; `RequestFailed` aliases `ApiError` for rescues.
- Retries on HTTP 429 using `Retry-After` (up to `configuration.max_retries`).
- RSpec suite with WebMock.

### Changed

- **Default model** is `gpt-image-1` (was DALL·E 2–era `image-alpha-001`).
- **Default size** is `1024x1024` (was `512x512`).
- Preferred API key env var is **`OPENAI_API_KEY`**; **`DALL_E_API_KEY`** remains a fallback.

### Removed

- Runtime dependencies on `sinatra`, `openai`, and pinned `json` / `net-http` (stdlib `net/http` + `json` only).

### Deprecated

- `Client#generate_image` — use `#generate`; emits a deprecation warning on stderr.

### Migration

- Replace `client.generate_image("prompt", opts)` with `client.generate("prompt", **opts)` and use `Response` (`#url` / `#b64`) or `#to_h` for a v1-like hash.

---

## [1.x]

Earlier releases targeted the legacy Images API with DALL·E 2 defaults. OpenAI has announced sunset timelines for older image models; prefer GPT Image models in new code.

[2.0.0]: https://github.com/merouaneamqor/generate_image/releases
