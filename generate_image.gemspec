require_relative 'lib/generate_image/version'

Gem::Specification.new do |spec|
  spec.name          = "generate_image"
  spec.version       = GenerateImage::VERSION
  spec.authors       = ["AMQOR Merouane"]
  spec.email         = ["marouane.amqor6@gmail.com"]

  spec.summary       = "Generate images using the DALL-E API"
  spec.description   = "Unleash your imagination and create stunning images with the 'generate_image' gem. This Ruby gem provides a seamless interface for accessing the powerful DALL-E API and generates images based on the text you provide. Perfect for Ruby on Rails projects, but can also be used in other Ruby projects."
  spec.homepage      = "https://github.com/merouaneamqor/generate_image"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.add_dependency "net-http"
  spec.add_dependency 'sinatra'
  spec.add_dependency 'json'
  spec.add_dependency 'openai'
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.files = Dir['lib/**/*', 'bin/*', 'LICENSE.txt', 'README.md']
  spec.files -= Dir['generate_image-*.gem']

end
