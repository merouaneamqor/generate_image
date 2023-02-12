# GenerateImage
The generate_image gem is a Ruby gem that provides a simple and easy-to-use interface for generating images using the DALL-E API. The gem is designed to be used in Ruby on Rails projects, but it can also be used in other Ruby projects.

The gem provides a generate_image method, which takes a text argument and returns the generated image binary data. The method makes a request to the DALL-E API to generate an image based on the text, and returns the image binary data.

The gem uses the Net::HTTP library to make the API request and it requires the API key to be set as an environment variable named DALL_E_API_KEY. The gem also includes error handling to ensure that the image generation is successful and raises an error if there's any issue.

## Installation
To install the gem, add this line to your application's Gemfile:

    gem 'generate_image'
### Then run:
    
    bundle install
### Or install it directly by running:


    gem install generate_image

## Development
### To contribute to the development of this gem, check out the repo and run the following commands to install dependencies and run the tests:

    bin/setup
    rake spec
You can also run bin/console for an interactive prompt to experiment with the code.

### To release a new version, update the version number in version.rb, then run:

    bundle exec rake release
This will create a git tag for the new version, push the git commits and tags, and upload the .gem file to rubygems.org.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/merouaneamqor/generate_image. This project is intended to be a safe, welcoming space for collaboration, and all contributors are expected to adhere to the code of conduct.

## License
The gem is available as open source under the terms of the MIT License.

## Code of Conduct
Everyone interacting with the project is expected to follow the code of conduct.
