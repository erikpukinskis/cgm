# typed: strict

class CalculateMetrics::GlucoseSummaryJob < ApplicationJob
  extend T::Sig
  queue_as :default

  sig { params(member_id: Integer, preceding_timestamp: DateTime).void }
  def perform(member_id:, preceding_timestamp:)
    Metrics::GlucoseSummary.create_all_for_timestamp!(
      member: Member.find(member_id),
      preceding_timestamp: preceding_timestamp)
  end
end
