# GenerateImage
The GenerateImage gem is a Ruby gem that provides a unified interface for generating images using multiple AI image generation APIs. It supports OpenAI DALL-E, Stability AI, Hugging Face, and allows easy extension to other providers.

## Installation
Add this line to your application's Gemfile:

    gem 'generate_image'

And then execute:

    bundle install

Or install it directly by running:

    gem install generate_image
## Usage

The gem provides a unified interface for multiple image generation APIs. You can use the default OpenAI provider or configure other providers like Stability AI, Hugging Face, or custom APIs.

### Quick Start

```ruby
require 'generate_image'

# Set API keys as environment variables
ENV['OPENAI_API_KEY'] = 'your_openai_key'
ENV['STABILITY_API_KEY'] = 'your_stability_key'
ENV['HUGGINGFACE_API_KEY'] = 'your_huggingface_key'

# Use the convenience method (defaults to OpenAI)
result = GenerateImage.generate_image('A futuristic city')
puts result[:image_url]
```

### Using Different Providers

```ruby
# Use OpenAI (default)
result = GenerateImage.generate_image('A cat playing piano', provider: :openai)

# Use Stability AI
result = GenerateImage.generate_image('A cat playing piano',
  provider: :stability_ai,
  model: 'stable-diffusion-v1-5'
)

# Use Hugging Face
result = GenerateImage.generate_image('A cat playing piano',
  provider: :hugging_face,
  model: 'CompVis/stable-diffusion-v1-4'
)
```

### Advanced Configuration

```ruby
# Configure providers and settings
GenerateImage.configure do |config|
  # Set default provider
  config.default_provider = :stability_ai

  # Register custom provider with API key
  config.register_provider(:my_custom, MyCustomProvider, 'custom_api_key')
end

# Use configured default
client = GenerateImage::Client.new
result = client.generate_image('A beautiful sunset')
```

### Using Client Class

```ruby
# Specify provider explicitly
client = GenerateImage::Client.new(:stability_ai)

# Get provider information
puts "Available models: #{client.available_models}"
puts "Supported sizes: #{client.supported_sizes}"
puts "Provider: #{client.provider_name}"

# Generate image
result = client.generate_image('A mountain landscape',
  model: 'stable-diffusion-xl',
  size: '1024x1024'
)
```

## Providers and API Keys

The gem supports multiple image generation providers. Set the appropriate environment variables for the providers you want to use:

- **OpenAI**: `OPENAI_API_KEY` or `DALL_E_API_KEY`
- **Stability AI**: `STABILITY_API_KEY`
- **Hugging Face**: `HUGGINGFACE_API_KEY`
- **Custom API**: Configure programmatically

### Built-in Providers

| Provider | Environment Variable | Models |
|----------|---------------------|---------|
| OpenAI | `OPENAI_API_KEY` | dall-e-2, dall-e-3, gpt-image-1 |
| Stability AI | `STABILITY_API_KEY` | stable-diffusion-v1-5, stable-diffusion-xl |
| Hugging Face | `HUGGINGFACE_API_KEY` | CompVis/stable-diffusion-v1-4, etc. |

## Options

The generate_image method accepts a hash of options to customize the generated images. Options vary by provider:

### Common Options (all providers)
- `provider` - The provider to use (`:openai`, `:stability_ai`, `:hugging_face`, etc.)
- `model` - The model to use (provider-specific)
- `num_images` - Number of images to generate (default: 1)
- `size` - Image dimensions (provider-specific, default: '1024x1024')

### OpenAI Provider Options
- `model`: `dall-e-2`, `dall-e-3`, `gpt-image-1` (default: `dall-e-2`)
- `size`: `256x256`, `512x512`, `1024x1024` (dall-e-2); `1024x1024`, `1792x1024`, `1024x1792` (dall-e-3)
- `response_format`: `url`, `b64_json` (default: `url`)
- `quality`: `standard`, `hd` (dall-e-3 only)
- `style`: `vivid`, `natural` (dall-e-3 only)
- `user`: User identifier for monitoring

### Stability AI Provider Options
- `model`: `stable-diffusion-v1-5`, `stable-diffusion-xl`, etc.
- `size`: `256x256`, `512x512`, `768x768`, `1024x1024`, etc.
- `steps`: Number of inference steps (default: 20)
- `cfg_scale`: Classifier-free guidance scale (default: 7)
- `style_preset`: Style preset to use

### Hugging Face Provider Options
- `model`: Model ID (e.g., `CompVis/stable-diffusion-v1-4`)
- `steps`: Number of inference steps (default: 20)
- `guidance_scale`: Guidance scale (default: 7.5)
- `negative_prompt`: Negative prompt for image generation

## Creating Custom Providers

You can easily create custom providers for other APIs:

```ruby
class MyCustomProvider < GenerateImage::HTTPProvider
  def initialize(api_key = nil)
    super(api_key, 'https://my-custom-api.com')
  end

  def build_endpoint(options)
    "#{@base_url}/v1/generate"
  end

  def build_request_body(prompt, options)
    {
      prompt: prompt,
      model: options[:model] || 'default',
      width: options[:size].split('x')[0].to_i,
      height: options[:size].split('x')[1].to_i
    }
  end

  def available_models
    ['model1', 'model2']
  end
end

# Register your custom provider
GenerateImage.configure do |config|
  config.register_provider(:my_custom, MyCustomProvider, 'your_api_key')
end

# Use it
result = GenerateImage.generate_image('test', provider: :my_custom)
```

## Development
To contribute to the development of this gem, clone the repository and run the following commands to install dependencies and run tests:

    bin/setup
    rake spec
You can also run bin/console for an interactive prompt to experiment with the code.

To release a new version, update the version number in version.rb and run:

    bundle exec rake release

This will create a git tag for the new version, push the git commits and tags, and upload the .gem file to RubyGems.org.

## Contributing
Bug reports and pull requests are welcome on the GitHub repository. This project is intended to be a safe and welcoming space for collaboration, and all contributors are expected to adhere to the code of conduct.

## License
The GenerateImage gem is open source software, released under the terms of the MIT License.
