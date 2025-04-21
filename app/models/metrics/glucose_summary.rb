# typed: strict

class Metrics::GlucoseSummary < ApplicationRecord
  extend T::Sig
  belongs_to :member

  sig { params(member: Member, preceding_timestamp: DateTime).void }
  def self.generate_if_needed!(member:, preceding_timestamp:)
    # Check if a job already exists
    existing_job = SolidQueue::Job.where(
      class_name: "CalculateMetrics::GlucoseSummaryJob",
      arguments: [ { member_id: member.id, preceding_timestamp: preceding_timestamp.to_s }.to_json ]
    ).where.not(finished_at: nil).exists?

    if existing_job
      return
    end

    CalculateMetrics::GlucoseSummaryJob.perform_later(user_id: member.id, preceding_timestamp: preceding_timestamp)
  end
end
