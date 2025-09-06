# GenerateImage Release Notes

## Version 2.0.0 (Latest)

### 🚀 Major Features

#### Multi-Provider Architecture
- **Complete rewrite** with extensible provider system
- Support for multiple image generation APIs out of the box
- Easy addition of custom providers for any image API

#### Built-in Provider Support
- **OpenAI** (DALL-E 2/3, GPT-Image-1)
- **Stability AI** (Stable Diffusion models)
- **Hugging Face** (Inference API models)
- **HTTP Provider** (Generic template for REST APIs)

#### Configuration System
```ruby
GenerateImage.configure do |config|
  config.default_provider = :stability_ai
  config.register_provider(:custom, MyProvider, 'api_key')
end
```

### 🔧 Enhancements

#### Provider Switching
```ruby
# Switch between providers easily
GenerateImage.generate_image('prompt', provider: :openai)
GenerateImage.generate_image('prompt', provider: :stability_ai)
GenerateImage.generate_image('prompt', provider: :hugging_face)
```

#### Provider Information
```ruby
client = GenerateImage::Client.new(:stability_ai)
puts client.available_models   # ["stable-diffusion-v1-5", ...]
puts client.supported_sizes    # ["512x512", "1024x1024", ...]
puts client.provider_name      # "stability_ai"
```

#### Updated Dependencies
- OpenAI SDK: `0.3.0` → `0.22.1`
- Sinatra: `3.0.5` → `4.1`
- Net-HTTP: `0.3.2` → `0.6.0`
- JSON: `2.6.3` → `2.13`
- Ruby requirement: `>= 2.3.0` → `>= 2.7.0`

### 📋 API Keys Support

| Provider | Environment Variable | Description |
|----------|---------------------|-------------|
| OpenAI | `OPENAI_API_KEY` | Primary API key |
| OpenAI | `DALL_E_API_KEY` | Backward compatibility |
| Stability AI | `STABILITY_API_KEY` | Stability AI API key |
| Hugging Face | `HUGGINGFACE_API_KEY` | Hugging Face API key |

### 🛠️ Breaking Changes

#### Environment Variables
- `DALL_E_API_KEY` still supported but `OPENAI_API_KEY` is preferred

#### Method Signatures
- All existing method signatures preserved
- New `provider` option available in all methods

#### Default Behavior
- Default provider is now configurable (defaults to `:openai`)
- Image size default changed from `512x512` to `1024x1024`

### 🔄 Migration Guide

#### From v1.x to v2.0.0

**No action required for basic usage:**
```ruby
# This still works exactly the same
ENV['OPENAI_API_KEY'] = 'your_key'
result = GenerateImage.generate_image('A beautiful sunset')
```

**To use multiple providers:**
```ruby
# Set multiple API keys
ENV['OPENAI_API_KEY'] = 'openai_key'
ENV['STABILITY_API_KEY'] = 'stability_key'
ENV['HUGGINGFACE_API_KEY'] = 'hf_key'

# Use different providers
openai_result = GenerateImage.generate_image('prompt', provider: :openai)
stability_result = GenerateImage.generate_image('prompt', provider: :stability_ai)
hf_result = GenerateImage.generate_image('prompt', provider: :hugging_face)
```

**Advanced configuration:**
```ruby
GenerateImage.configure do |config|
  config.default_provider = :stability_ai
end

# Now uses Stability AI by default
result = GenerateImage.generate_image('prompt')
```

### 🆕 New Features

#### Custom Provider Creation
```ruby
class MyCustomProvider < GenerateImage::HTTPProvider
  def build_endpoint(options)
    "#{@base_url}/v1/generate"
  end

  def build_request_body(prompt, options)
    { prompt: prompt, model: options[:model] }
  end
end

GenerateImage.configure do |config|
  config.register_provider(:my_api, MyCustomProvider, 'api_key')
end
```

#### Provider-Specific Options

**OpenAI Options:**
- `quality`: `standard`, `hd` (DALL-E 3)
- `style`: `vivid`, `natural` (DALL-E 3)
- `user`: User identifier

**Stability AI Options:**
- `steps`: Inference steps (default: 20)
- `cfg_scale`: Guidance scale (default: 7)
- `style_preset`: Style presets

**Hugging Face Options:**
- `guidance_scale`: Guidance scale (default: 7.5)
- `negative_prompt`: Negative prompts
- `steps`: Inference steps (default: 20)

### 🐛 Bug Fixes

- Improved error handling for all providers
- Better validation of prompts and options
- Fixed response parsing for different API formats
- Enhanced timeout and retry logic

### 📚 Documentation

- Complete README with multi-provider examples
- Provider-specific configuration guides
- Custom provider creation tutorial
- Comprehensive API reference

### 🔒 Security

- API keys properly masked in logs
- Secure handling of authentication headers
- Input validation for all parameters
- No sensitive data in error messages

### 🧪 Testing

- Comprehensive test suite covering all providers
- Mock implementations for reliable testing
- Provider switching tests
- Configuration system tests

---

## Previous Versions

### Version 1.1.2.1
- Initial OpenAI DALL-E integration
- Basic image generation functionality
- Single provider support

---

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:
- Adding new providers
- Reporting bugs
- Feature requests
- Code style guidelines

## Support

- 📖 [Documentation](README.md)
- 🐛 [Issue Tracker](https://github.com/your-repo/issues)
- 💬 [Discussions](https://github.com/your-repo/discussions)

---

*Released on: [Current Date]*
*Checksum: [Gem Checksum]*
