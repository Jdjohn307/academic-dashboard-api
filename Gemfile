source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.1"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.6"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# ActiveModelSerializers allows you to control how your Rails models are rendered as JSON.
# Useful for APIs to structure output and include relationships.
# Docs: https://github.com/rails-api/active_model_serializers
# Gem:  https://rubygems.org/gems/active_model_serializers
gem "active_model_serializers", "~> 0.10.15"

# JSON:API support for Rails controllers — provides request/response formatting, error handling, and integration with jsonapi-serializer.
# Follows the JSON:API spec: https://jsonapi.org/
# Docs: https://github.com/jsonapi-rb/jsonapi-rails
# Gem:  https://rubygems.org/gems/jsonapi-rails
gem "jsonapi-rails", "~> 0.4.1"

# Fast and efficient pagination library for Ruby on Rails.
# Docs: https://ddnexus.github.io/pagy/guides/quick-start/
gem "pagy", "~> 43.1" # Omit the patch segment to avoid breaking changes

# Fast and flexible serializer for generating JSON:API-compliant output.
# Successor to fast_jsonapi — compatible with jsonapi-rails.
# Docs: https://github.com/jsonapi-serializer/jsonapi-serializer
# Gem:  https://rubygems.org/gems/jsonapi-serializer
gem "jsonapi-serializer", "~> 2.2"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.20"

# JWT: JSON Web Token implementation in Ruby.
# Github: https://github.com/jwt/ruby-jwt
gem "jwt"

# Rate Limitting / Throttling
# Github: https://github.com/rack/rack-attack
gem "rack-attack"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", "~> 7.1.1"

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # RSpec: Behavior-driven test framework for Ruby
  # GitHub: https://github.com/rspec/rspec-rails
  # RubyGems: https://rubygems.org/gems/rspec-rails
  gem "rspec-rails"

  # FactoryBot: Fixtures replacement for generating test data
  # GitHub: https://github.com/thoughtbot/factory_bot_rails
  # RubyGems: https://rubygems.org/gems/factory_bot_rails
  gem "factory_bot_rails"

  # Database Cleaner: Cleans the database between tests to ensure isolation
  # GitHub: https://github.com/DatabaseCleaner/database_cleaner-active_record
  # RubyGems: https://rubygems.org/gems/database_cleaner-active_record
  gem "database_cleaner-active_record"

  # Rswag: Seamlessly integrate Swagger with Rails APIs
  # GitHub: https://github.com/rswag/rswag
  gem "rswag"

  gem "dotenv-rails"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"

  # Shoulda Matchers: RSpec matchers for testing validations and associations
  # GitHub: [https://github.com/thoughtbot/shoulda-matchers]
  gem "shoulda-matchers", "~> 7.0"
end
