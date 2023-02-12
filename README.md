# GenerateImage

The 'image_generator' gem is a Ruby gem that provides a simple and easy-to-use interface for generating images using the DALL-E API. The gem is designed to be used in Ruby on Rails projects, but it can also be used in other Ruby projects.

The gem provides a generate_image method, which takes a text argument and returns the generated image binary data. The method makes a request to the DALL-E API to generate an image based on the text, and returns the image binary data.

The gem uses the Net::HTTP library to make the API request, and it requires the API key to be set as an environment variable named DALL_E_API_KEY. The gem also includes error handling to ensure that the image generation is successful and to raise an error if there's any issue.

To use the gem, you simply need to add it to your Rails project's Gemfile and run bundle install. You can then use the generate_image method in your Rails controllers to generate images and send them to the client.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'generate_image'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install generate_image

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/generate_image. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/generate_image/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GenerateImage project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/generate_image/blob/master/CODE_OF_CONDUCT.md).
