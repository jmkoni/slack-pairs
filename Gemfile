source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.4"

gem "rails", "~> 8.0.1"
gem "puma"
gem "sentry-ruby"
gem "sentry-rails"
gem "slack-ruby-client"
gem "bootsnap", ">= 1.4.4", require: false

group :development, :test do
  gem "dotenv-rails"
  gem "pry"
  gem "standard"
end

group :development do
  gem "rack-mini-profiler"
  gem "listen"
  gem "yard"
end

group :test do
  gem "ostruct"
  gem "rspec"
  gem "rspec-rails"
  gem "simplecov"
  gem "webmock"
end
