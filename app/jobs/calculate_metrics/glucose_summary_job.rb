# typed: strict

class CalculateMetrics::GlucoseSummaryJob < ApplicationJob
  extend T::Sig
  queue_as :default

  sig { params(user_id: Integer, preceding_timestamp: DateTime).void }
  def perform(user_id:, preceding_timestamp:)
    # Do something later
  end
end
