source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.0"

gem "rails", "~> 6.1.3", ">= 6.1.3.1"
gem "puma", "~> 5.0"
gem "simple_scheduler"
gem "slack-ruby-client"
gem "bootsnap", ">= 1.4.4", require: false

group :development, :test do
  gem "pry"
  gem "standard"
end

group :development do
  gem "rack-mini-profiler", "~> 2.0"
  gem "listen", "~> 3.3"
end

group :test do
  gem "rspec"
end
