require_relative 'lib/generate_image/version'

Gem::Specification.new do |spec|
  spec.name          = "generate_image"
  spec.version       = GenerateImage::VERSION
  spec.authors       = ["AMQOR Merouane"]
  spec.email         = ["marouane.amqor@gmail.com"]

  spec.summary       = "Generate images using the DALL-E API"
  spec.description   = "The 'generate_image' gem provides a simple and easy-to-use interface for generating images using the powerful DALL-E API from OpenAI. This Ruby gem can be used in Ruby on Rails projects or any other Ruby projects to create stunning images based on the text you provide. Unleash your imagination and generate images for any use case, from social media posts to marketing materials and beyond."
  spec.homepage      = "https://github.com/merouaneamqor/generate_image"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.add_dependency "net-http", "~> 0.3.2"
  spec.add_dependency 'sinatra', "~> 3.0.5"
  spec.add_dependency 'json', "~> 2.6.3"
  spec.add_dependency 'openai', "~> 0.3.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.files = Dir['lib/**/*', 'bin/*', 'LICENSE.txt', 'README.md']
  spec.files -= Dir['generate_image-*.gem']

end
