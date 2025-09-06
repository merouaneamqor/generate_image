# Changelog

All notable changes to GenerateImage will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - [Current Date]

### Added
- ✨ **Multi-provider architecture** - Support for OpenAI, Stability AI, Hugging Face, and custom APIs
- 🚀 **Provider system** - Abstract provider interface with concrete implementations
- 🔧 **Configuration system** - Easy provider registration and default provider selection
- 📦 **Built-in providers**:
  - OpenAI Provider (DALL-E 2/3, GPT-Image-1)
  - Stability AI Provider (Stable Diffusion models)
  - Hugging Face Provider (Inference API models)
  - HTTP Provider (Generic REST API template)
- 🆕 **Provider switching** - Change providers with `provider: :name` option
- 📊 **Provider information** - Access available models, sizes, and capabilities
- 🔒 **Enhanced security** - Better API key handling and input validation
- 🧪 **Comprehensive testing** - Full test coverage for all providers
- 📖 **Extensive documentation** - Multi-provider usage examples and guides

### Changed
- 🔄 **Updated dependencies**:
  - OpenAI SDK: `0.3.0` → `0.22.1`
  - Sinatra: `3.0.5` → `4.1`
  - Net-HTTP: `0.3.2` → `0.6.0`
  - JSON: `2.6.3` → `2.13`
- 📏 **Default image size**: `512x512` → `1024x1024`
- 🏗️ **Architecture overhaul** - Complete rewrite with provider pattern
- 🎯 **Ruby requirement**: `>= 2.3.0` → `>= 2.7.0`

### Deprecated
- ⚠️ `DALL_E_API_KEY` - Use `OPENAI_API_KEY` instead (still supported for compatibility)

### Removed
- ❌ Legacy HTTP request implementation (replaced with provider system)

### Fixed
- 🐛 Improved error handling across all providers
- 🔧 Better response parsing for different API formats
- ⚡ Enhanced timeout and retry mechanisms
- 🛡️ Input validation for all parameters

### Security
- 🔐 API keys properly masked in logs
- 🛡️ Secure authentication header handling
- ✅ No sensitive data exposure in error messages

## [1.1.2.1] - [Previous Date]

### Added
- 🎨 Initial OpenAI DALL-E integration
- 🖼️ Basic image generation functionality
- 🔑 Environment variable configuration
- 📝 Error handling and validation

### Changed
- 📦 Updated to latest OpenAI SDK version available at time

### Fixed
- 🐛 Various API integration bugs
- 📊 Response parsing improvements

---

## Types of changes
- `Added` for new features
- `Changed` for changes in existing functionality
- `Deprecated` for soon-to-be removed features
- `Removed` for now removed features
- `Fixed` for any bug fixes
- `Security` in case of vulnerabilities

## Version Format
This project uses [Semantic Versioning](https://semver.org/):
- **MAJOR.MINOR.PATCH** (e.g., 2.0.0)
- **MAJOR**: Breaking changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible
