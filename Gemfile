source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.3"

gem "rails", "~> 7.0", ">= 7.0.4"
gem "puma", "~> 5.0"
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
  gem "rack-mini-profiler", "~> 2.0"
  gem "listen", "~> 3.3"
  gem "yard"
end

group :test do
  gem "rspec"
  gem "rspec-rails"
  gem "simplecov"
  gem "webmock"
end
