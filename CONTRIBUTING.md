# Contributing to GenerateImage

Thank you for your interest in contributing to GenerateImage! 🎉

This document provides guidelines and information for contributors. Whether you're fixing bugs, adding features, improving documentation, or helping with tests, your contributions are welcome and appreciated.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Contributing Guidelines](#contributing-guidelines)
- [Adding New Providers](#adding-new-providers)
- [Testing](#testing)
- [Code Style](#code-style)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)
- [License](#license)

## 🤝 Code of Conduct

This project follows a code of conduct to ensure a welcoming environment for all contributors. By participating, you agree to:

- Be respectful and inclusive
- Focus on constructive feedback
- Accept responsibility for mistakes
- Show empathy towards other contributors
- Help create a positive community

## 🚀 Getting Started

### Prerequisites

- Ruby 3.2.0 or higher (required by openai gem)
- Bundler gem (comes with Ruby 3.2+)
- Git

### Quick Setup

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/your-username/generate_image.git
   cd generate_image
   ```
3. **Run the automated setup script**:
   ```bash
   ./script/setup
   ```
   Or manually:
   ```bash
   bundle install
   bundle exec rake quality
   ```
4. **Run tests** to ensure everything works:
   ```bash
   bundle exec rspec
   ```

## 🛠️ Development Setup

### Detailed Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/merouaneamqor/generate_image.git
   cd generate_image
   ```

2. **Install Ruby dependencies**:
   ```bash
   bundle install
   ```

3. **Set up your development environment**:
   ```bash
   # Copy environment template if available
   cp .env.example .env  # if exists

   # Set up API keys for testing
   export OPENAI_API_KEY="your_test_key"
   export STABILITY_API_KEY="your_test_key"
   export HUGGINGFACE_API_KEY="your_test_key"
   ```

4. **Run the test suite**:
   ```bash
   bundle exec rspec
   ```

5. **Start a development console**:
   ```bash
   bundle exec rake console
   ```

### Development Commands

```bash
# Run tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/generate_image_spec.rb

# Run tests with coverage
bundle exec rspec --coverage

# Lint code
bundle exec rubocop

# Auto-fix linting issues
bundle exec rubocop -a

# Generate documentation
bundle exec rake docs

# Build gem
bundle exec rake build

# Install gem locally
bundle exec rake install
```

## 🏗️ Project Structure

```
generate_image/
├── bin/                          # Executable scripts
├── lib/
│   ├── generate_image.rb         # Main module
│   ├── generate_image/
│   │   ├── providers.rb          # Provider loader
│   │   ├── providers/
│   │   │   ├── openai.rb         # OpenAI provider
│   │   │   ├── stability_ai.rb   # Stability AI provider
│   │   │   ├── hugging_face.rb   # Hugging Face provider
│   │   │   └── http_provider.rb  # Generic HTTP provider
│   │   └── version.rb            # Version information
├── spec/                         # Test files
│   ├── generate_image_spec.rb    # Main test suite
│   └── spec_helper.rb           # Test configuration
├── .github/                      # GitHub configuration
├── CHANGELOG.md                  # Change history
├── RELEASE_NOTES.md              # Release information
├── README.md                     # Main documentation
├── Rakefile                      # Build tasks
├── generate_image.gemspec        # Gem specification
└── CONTRIBUTING.md               # This file
```

## 📝 Contributing Guidelines

### Types of Contributions

- 🐛 **Bug fixes** - Fix existing issues
- ✨ **Features** - Add new functionality
- 📚 **Documentation** - Improve docs or examples
- 🧪 **Tests** - Add or improve test coverage
- 🔧 **Tools** - Development tools and scripts
- 🎨 **UI/UX** - Improve user experience

### Development Workflow

1. **Choose an issue** or create one for your contribution
2. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/issue-number-description
   ```
3. **Make your changes** following the guidelines below
4. **Write tests** for your changes
5. **Run the test suite** and ensure all tests pass
6. **Update documentation** if needed
7. **Commit your changes** with clear messages
8. **Push to your fork** and create a Pull Request

### Commit Messages

Use clear, descriptive commit messages:

```bash
# Good
git commit -m "Add Stability AI provider support"

# Better
git commit -m "feat: add Stability AI provider with SD models

- Implement StabilityAIProvider class
- Add support for stable-diffusion-v1-5 and XL models
- Include proper error handling and response parsing
- Add comprehensive tests for the new provider"

# Types: feat, fix, docs, style, refactor, test, chore
```

## 🔌 Adding New Providers

GenerateImage is designed to be easily extensible. Here's how to add a new provider:

### 1. Create Provider Class

Create a new file in `lib/generate_image/providers/your_provider.rb`:

```ruby
module GenerateImage
  class YourProvider < Provider
    def initialize(api_key = nil)
      super(api_key || ENV['YOUR_PROVIDER_API_KEY'])
      @base_url = ENV['YOUR_PROVIDER_BASE_URL'] || 'https://api.yourprovider.com'
    end

    def generate_image(prompt, options = {})
      validate_prompt(prompt)

      # Implement your API logic here
      # Return hash with :image_url or :image_base64
    end

    def available_models
      ['model1', 'model2']
    end

    def supported_sizes
      ['512x512', '1024x1024']
    end
  end
end
```

### 2. Register Provider

Update `lib/generate_image.rb` to include your provider:

```ruby
def register_builtin_providers
  register_provider(:openai, OpenAIProvider)
  register_provider(:stability_ai, StabilityAIProvider)
  register_provider(:hugging_face, HuggingFaceProvider)
  register_provider(:your_provider, YourProvider)  # Add this line
end
```

### 3. Update Provider Loader

Update `lib/generate_image/providers.rb`:

```ruby
require_relative 'providers/openai'
require_relative 'providers/stability_ai'
require_relative 'providers/hugging_face'
require_relative 'providers/http_provider'
require_relative 'providers/your_provider'  # Add this line
```

### 4. Add Tests

Create comprehensive tests in `spec/generate_image_spec.rb`:

```ruby
describe GenerateImage::YourProvider do
  # Test implementation details
  # Test error handling
  # Test different options
end
```

### 5. Update Documentation

- Add your provider to `README.md`
- Update `RELEASE_NOTES.md` if this is a new feature
- Add provider-specific options to the documentation

### Provider Template

For REST APIs, extend `HTTPProvider`:

```ruby
class YourAPIProvider < HTTPProvider
  def initialize(api_key = nil)
    super(api_key, 'https://your-api.com')
  end

  def build_endpoint(options)
    "#{@base_url}/v1/generate"
  end

  def build_request_body(prompt, options)
    {
      prompt: prompt,
      model: options[:model],
      width: options[:size].split('x')[0].to_i,
      height: options[:size].split('x')[1].to_i
    }
  end
end
```

## 🧪 Testing

### Running Tests Locally

```bash
# Run all tests
bundle exec rspec

# Run specific test
bundle exec rspec spec/generate_image_spec.rb

# Run tests with coverage
bundle exec rspec --coverage

# Run tests in verbose mode
bundle exec rspec --format documentation
```

### CI/CD Pipeline

The project uses GitHub Actions for automated testing:

- **Multi-Ruby Testing**: Tests run on Ruby 3.2 and 3.3 (compatible with openai gem)
- **Parallel Jobs**: Separate jobs for testing, linting, and building
- **Security Audits**: Automated vulnerability scanning with bundle audit
- **Code Quality**: RuboCop linting with GitHub integration
- **Automated Releases**: Publishing to RubyGems on version tags
- **Dependency Updates**: Dependabot for automated dependency management

### Writing Tests

- Use RSpec for all tests
- Place tests in `spec/` directory
- Follow the existing test patterns
- Test both success and error cases
- Mock external API calls to avoid rate limits
- Test provider-specific functionality

Example test structure:

```ruby
describe GenerateImage::YourProvider do
  let(:provider) { GenerateImage::YourProvider.new('test_key') }

  describe '#generate_image' do
    it 'generates an image successfully' do
      # Test implementation
    end

    it 'handles API errors gracefully' do
      # Test error handling
    end
  end

  describe '#available_models' do
    it 'returns supported models' do
      expect(provider.available_models).to include('model1')
    end
  end
end
```

### Test Coverage

- Aim for >90% test coverage
- Test all public methods
- Test edge cases and error conditions
- Mock external dependencies

## 🎨 Code Style

### Ruby Style Guide

Follow the [Ruby Style Guide](https://rubygems.org/gems/rubocop) and use RuboCop:

```bash
# Check style
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a
```

### Key Conventions

- Use 2 spaces for indentation
- Use snake_case for methods and variables
- Use CamelCase for classes and modules
- Add documentation for public methods
- Keep methods small and focused
- Use meaningful variable names

### Documentation

- Use YARD format for documentation
- Document all public methods
- Include parameter types and return values
- Add examples for complex functionality

Example:

```ruby
# @param prompt [String] The text prompt for image generation
# @param options [Hash] Additional options for generation
# @return [Hash] Response containing :image_url or :image_base64
# @example
#   provider.generate_image("A beautiful sunset", model: "dall-e-3")
def generate_image(prompt, options = {})
  # implementation
end
```

## 🔄 Submitting Changes

### Pull Request Process

1. **Ensure tests pass**:
   ```bash
   bundle exec rspec
   ```

2. **Check code style**:
   ```bash
   bundle exec rubocop
   ```

3. **Update documentation** if needed

4. **Create a Pull Request**:
   - Use a clear, descriptive title
   - Provide detailed description of changes
   - Reference any related issues
   - Include screenshots for UI changes

5. **Respond to feedback** and make requested changes

### Pull Request Template

A pull request template is available at `.github/PULL_REQUEST_TEMPLATE.md` to help you structure your PR properly. It includes:

- Description of changes
- Type of change checkboxes
- Testing checklist
- File modification summary
- Related issues linking

## 🐛 Reporting Issues

### Issue Templates

GitHub issue templates are available to help you report issues effectively:

- **Bug Report Template** (`.github/ISSUE_TEMPLATE/bug_report.md`)
- **Feature Request Template** (`.github/ISSUE_TEMPLATE/feature_request.md`)

### Bug Reports

When reporting bugs, please include:

1. **Clear title** describing the issue
2. **Steps to reproduce** the problem
3. **Expected behavior** vs actual behavior
4. **Environment details**:
   - Ruby version
   - Gem version
   - Operating system
   - Provider being used
5. **Error messages** and stack traces
6. **Code samples** if applicable

### Feature Requests

For feature requests, please include:

1. **Clear description** of the proposed feature
2. **Use case** - why is this feature needed?
3. **Implementation ideas** if you have any
4. **Alternatives considered**

### Using Issue Templates

The issue templates will guide you through providing all necessary information, making it easier for maintainers to understand and address your issue quickly.

## 📄 License

By contributing to GenerateImage, you agree that your contributions will be licensed under the same license as the project (MIT License).

## 🙏 Recognition

Contributors will be acknowledged in:
- CHANGELOG.md for their contributions
- GitHub contributors list
- Release notes

Thank you for contributing to GenerateImage! 🚀
