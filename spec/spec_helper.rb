# frozen_string_literal: true

require "bundler/setup"
require "webmock/rspec"
require "generate_image"

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    WebMock.reset!
    ENV.delete("OPENAI_API_KEY")
    ENV.delete("DALL_E_API_KEY")
    GenerateImage.instance_variable_set(:@configuration, GenerateImage::Configuration.new)
  end
end
