require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

# Run RuboCop for code quality
task :lint do
  sh 'bundle exec rubocop'
end

# Run security audit
task :audit do
  sh 'bundle exec bundle audit check --update'
end

# Run all quality checks
task quality: %i[spec lint audit]

# Build and test gem
task :build_and_test do
  sh 'bundle exec rake build'
  Dir.glob('pkg/generate_image-*.gem').each do |gem_file|
    sh "gem install #{gem_file} --no-document"
    sh "ruby -e \"require 'generate_image'; puts '✅ Gem installed successfully'\""
  end
end

task default: :quality
