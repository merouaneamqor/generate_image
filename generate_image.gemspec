# frozen_string_literal: true

require_relative "lib/generate_image/version"

Gem::Specification.new do |spec|
  spec.name = "generate_image"
  spec.version = GenerateImage::VERSION
  spec.authors = ["AMQOR Merouane"]
  spec.email = ["marouaneamqor@gmail.com"]

  spec.summary = "OpenAI Images API client (GPT Image, DALL·E) for Ruby"
  spec.description = <<~DESC
    Lightweight Ruby client for OpenAI image generation and edits (/v1/images/generations, /v1/images/edits).
    Defaults to GPT Image models; stdlib-only (Net::HTTP + JSON). Ruby 3.1+.
  DESC
  spec.homepage = "https://github.com/merouaneamqor/generate_image"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  rescue StandardError
    Dir["lib/**/*", "LICENSE.txt", "README.md", "CHANGELOG.md"]
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "webmock", "~> 3.19"
end
