# frozen_string_literal: true

source 'http://rubygems.org'

ruby RUBY_VERSION

gemspec

# gem 'grape', case version = ENV['GRAPE_VERSION'] || '>= 1.5.0'
#              when 'HEAD'
#                { git: 'https://github.com/ruby-grape/grape' }
#              else
#                version
#              end
gem 'grape', path: '../grape'

gem ENV['MODEL_PARSER'] if ENV.key?('MODEL_PARSER')

group :development, :test do
  gem 'bundler'
  gem 'grape-entity'
  gem 'pry', platforms: [:mri]
  gem 'pry-byebug', platforms: [:mri]

  gem 'rack', '~> 2.2'
  gem 'rack-cors'
  gem 'rack-test'
  gem 'rake'
  gem 'rdoc'
  gem 'rspec', '~> 3.9'
  gem 'rubocop', '~> 1.0', require: false
end

group :test do
  gem 'coveralls_reborn', require: false

  gem 'ruby-grape-danger', '~> 0.1.1', require: false
  gem 'simplecov', require: false

  gem 'grape-swagger-entity', path: '../grape-swagger-entity'
end
