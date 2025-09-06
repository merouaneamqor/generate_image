# Security Policy

## Supported Versions

We take security seriously. The following versions of GenerateImage are currently supported with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 2.0.x   | :white_check_mark: |
| 1.1.x   | :white_check_mark: |
| < 1.1   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in GenerateImage, please help us by reporting it responsibly.

### How to Report

1. **Do not** create a public GitHub issue for the vulnerability
2. **Email** security reports to: [security@generateimage.dev](mailto:security@generateimage.dev)
3. **Include** the following information:
   - A clear description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact and severity
   - Any suggested fixes or mitigations

### What to Expect

- **Acknowledgment**: We'll acknowledge receipt within 48 hours
- **Investigation**: We'll investigate and provide regular updates
- **Fix**: We'll work on a fix and coordinate disclosure
- **Credit**: We'll credit you (if desired) in the security advisory

### Responsible Disclosure

We follow responsible disclosure practices:

- We'll work with you to understand and fix the issue
- We'll coordinate public disclosure timing
- We'll credit your contribution appropriately
- We won't take legal action against security researchers

## Security Best Practices

When using GenerateImage, follow these security best practices:

### API Key Management

```ruby
# Never hardcode API keys
ENV['OPENAI_API_KEY'] = 'your_secure_key'

# Use environment variables or secure key management
# Avoid committing keys to version control
```

### Input Validation

```ruby
# Always validate inputs
prompt = params[:prompt]
raise "Invalid prompt" unless prompt.is_a?(String) && prompt.length > 0
```

### Error Handling

```ruby
# Don't expose sensitive information in errors
begin
  result = GenerateImage.generate_image(prompt)
rescue => e
  # Log full error internally
  logger.error("Image generation failed: #{e.message}")

  # Return safe error to user
  render json: { error: "Image generation failed" }
end
```

### Network Security

- Use HTTPS for all API communications
- Validate SSL certificates
- Consider using VPNs for sensitive deployments

## Security Updates

Security updates will be:

- Released as soon as possible
- Documented in release notes
- Communicated through:
  - GitHub Security Advisories
  - Release notes
  - Security mailing list (if established)

## Contact

For security-related questions or concerns:

- **Email**: security@generateimage.dev
- **PGP Key**: [Link to PGP key if available]
- **Response Time**: Within 48 hours

Thank you for helping keep GenerateImage secure! 🛡️
