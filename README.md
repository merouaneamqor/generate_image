# GenerateImage
The GenerateImage gem is a Ruby gem that provides an interface for generating images using the OpenAI DALL-E API. This gem can be used in Ruby on Rails projects or any other Ruby projects.

## Installation
Add this line to your application's Gemfile:

    gem 'generate_image'

And then execute:

    bundle install

Or install it directly by running:

    gem install generate_image
## Usage
The gem provides a generate_image method, which takes a text argument and returns the generated image URL or image base64 as a hash. The method makes a request to the DALL-E API to generate an image based on the provided text.

Before using the generate_image method, you must set your OpenAI API key as an environment variable named `DALL_E_API_KEY`. The gem uses the `Net::HTTP` library to make API requests and includes error handling to ensure successful image generation. In case of any errors, the method will raise a RequestFailed exception.

### Examples

    require 'generate_image'

    # Set the DALL-E API key
    ENV['DALL_E_API_KEY'] = 'your_api_key'

    # Generate a single image with default options
    result = GenerateImage.generate_image('A three-story castle made of ice cream')
    if result[:error]
      puts result[:error]
    else
      puts result[:image_url]
    end

    # Generate a single image with custom options
    result = GenerateImage.generate_image('A cat playing the piano', model: 'image-alpha-001', num_images: 2, size: '1024x1024', response_format: 'base64', quality: 90)
    if result[:error]
      puts result[:error]
    else
      puts result[:image_base64]
    end
## Options
The generate_image method accepts a hash of options to customize the generated images. Here are the available options:

`model` - The name of the model to use for generating the images. Default is `image-alpha-001`.

`num_images` - The number of images to generate. Default is `1`.

`size` - The dimensions of the generated images in the format widthxheight. Default is `512x512`.

`response_format` - The format of the response, either `url` or `base64`. Default is `url`.

`style` - The model or style to use for generating the images. Default is `nil`, which uses the default style of the selected model.

`scale` - The scaling factor for the generated image. Default is `1`.

`seed` - The random seed to use for the generation process. Default is `nil`.

`quality` - The JPEG compression quality of the generated image. Default is `80`.

`text_model` - The name of the model to use for generating text prompts. Default is `text-davinci-002`.

`text_prompt` - The text prompt to use for generating the image. Default is `nil`.

`text_length` - The maximum length of the generated text. Default is `nil`.

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
