ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Asserts that the given ActiveRecord model has the expected attributes
    #
    # @param model [ActiveRecord::Base] The model to compare against
    # @param expected [Hash] A hash of expected attribute values
    def assert_model_attributes(model, expected)
      expected.each do |key, value|
        if value.nil?
          assert_nil model.send(key),
            "Wrong #{key} on #{model.inspect}"

        else
          assert_equal value, model.send(key),
            "Wrong #{key} on #{model.inspect}"
        end
      end
    end
  end
end
