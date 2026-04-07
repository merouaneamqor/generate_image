# generate_image — AI assistant notes

Ruby gem: **OpenAI Images API** client (`/v1/images/generations`, `/v1/images/edits`). Stdlib only (`Net::HTTP`, `json`). **Ruby >= 3.1**.

## Layout

| Path | Role |
|------|------|
| `lib/generate_image.rb` | Entry; `GenerateImage.configure` |
| `lib/generate_image/client.rb` | `#generate`, `#edit`, deprecated `#generate_image` |
| `lib/generate_image/http.rb` | JSON POST, multipart POST, 429 retry |
| `lib/generate_image/configuration.rb` | Keys, defaults, timeouts |
| `lib/generate_image/models.rb` | Model/size constants |
| `lib/generate_image/response.rb` | Parsed API response |
| `lib/generate_image/errors.rb` | Error hierarchy |

## Conventions

- Do not add heavy runtime deps; keep generation HTTP in `HTTP`, validation in `Client`.
- Preserve backward compat: `DALL_E_API_KEY` fallback, `RequestFailed` alias, `#generate_image` delegation.
- API key: never log or persist keys; read from config or env only.

## Checks

From gem root: `bundle install` then `bundle exec rspec`.
