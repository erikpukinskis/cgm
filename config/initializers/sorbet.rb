# typed: false
# frozen_string_literal: true

# This file is used to configure Sorbet for your Rails application.
# It's loaded during initialization in development and test environments.

if Rails.env.development? || Rails.env.test?
  # Sorbet runtime settings can be configured here
  # T::Configuration.default_checked_level = :never
end
