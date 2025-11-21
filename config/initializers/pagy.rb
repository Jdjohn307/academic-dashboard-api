# config/initializers/pagy.rb
# frozen_string_literal: true

require "pagy"

Pagy.options[:limit] = 25         # Default items per page
Pagy.options[:overflow] = :last_page
Pagy.options[:jsonapi] = true  # Use JSON:API compliant URLs
