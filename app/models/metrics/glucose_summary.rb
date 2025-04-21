# typed: strict

HIGH_GLUCOSE_VALUE = 180
LOW_GLUCOSE_VALUE = 70

class Metrics::GlucoseSummary < ApplicationRecord
  extend T::Sig
  belongs_to :member
  # TODO: Using integers here while we have Sqlite in development. If we had Postgres
  # set up, we could use the enum type.
  enum :period, { week: 0, month: 1 }

  # Generates glucose summaries for the week and month preceding the given timestamp
  # @param member [Member] The member to generate the summaries for
  # @param preceding_timestamp [DateTime] The timestamp to summarize relative to
  # @return [Hash] containing the summaries
  sig { params(member: Member, preceding_timestamp: DateTime).returns({ week: Metrics::GlucoseSummary, month: Metrics::GlucoseSummary }) }
  def self.create_all_for_timestamp!(member:, preceding_timestamp:)
    week = Metrics::GlucoseSummary.new(
      member: member,
      preceding_timestamp: preceding_timestamp,
      period: :week,
      num_measurements: 0,
      average_glucose_level: nil,
      time_below_range: nil,
      time_above_range: nil
    )

    month = Metrics::GlucoseSummary.new(
      member: member,
      preceding_timestamp: preceding_timestamp,
      period: :month,
      num_measurements: 0,
      average_glucose_level: nil,
      time_below_range: nil,
      time_above_range: nil
    )

    start_of_last_7 = preceding_timestamp.beginning_of_day - 6.days
    start_of_month = preceding_timestamp.beginning_of_month

    member.measurements.between(start_time: start_of_month, end_time: preceding_timestamp).each do |measurement|
      if measurement.tested_at > preceding_timestamp
        raise "measurement was in the future?"
      end

      if measurement.tested_at > start_of_last_7
        add_measurement(week, measurement)
      end

      if measurement.tested_at > start_of_month
        add_measurement(month, measurement)
      end

      if measurement.tested_at < start_of_month
        raise "measurement was before the query start time?"
      end
    end

    week.save!
    month.save!

    {
      week: week,
      month: month
    }
  end

  # Tries to find GlucoseSummary records for the given parameters.
  # - If found, returns the summaries, under the keys :week and :month.
  # - If not found, returns nil.
  # - If not found and there's not already a GlucoseSummaryJob queued up, it queues one.
  #
  # @param member [Member] The member to find the summaries for
  # @param preceding_timestamp [DateTime] The timestamp to summarize relative to
  # @return [Hash{ week: Metrics::GlucoseSummary, month: Metrics::GlucoseSummary }] The summaries, grouped by period
  sig { params(member: Member, preceding_timestamp: DateTime).returns({ week: T.nilable(Metrics::GlucoseSummary), month: T.nilable(Metrics::GlucoseSummary)  }) }
  def self.find_or_queue(member:, preceding_timestamp:)
    # Check if a summary already exists
    week = Metrics::GlucoseSummary.where(
      period: :week,
      member: member,
      preceding_timestamp: preceding_timestamp
    ).first

    month = Metrics::GlucoseSummary.where(
      period: :month,
      member: member,
      preceding_timestamp: preceding_timestamp
    ).first

    # If the summaries don't exist, queue a job to calculate them
    if !week || !month
      # Check if a job already exists
      existing_job = SolidQueue::Job.where(
        class_name: "CalculateMetrics::GlucoseSummaryJob",
        arguments: [ { member_id: member.id, preceding_timestamp: preceding_timestamp.to_s }.to_json ]
      ).where.not(finished_at: nil).exists?

      # If the job doesn't exist, queue it
      if !existing_job
        CalculateMetrics::GlucoseSummaryJob.perform_later(member_id: member.id, preceding_timestamp: preceding_timestamp)
      end
    end

    {
      week: week,
      month: month
    }
  end

  private

  # Helper function that adds an additional glucose measurement to the given metrics.
  # @param metrics [Metrics::GlucoseSummary] The previous metrics to update
  # @param measurement [Measurement] The new measurement to add
  sig { params(metrics: Metrics::GlucoseSummary, measurement: Measurement).void }
  def self.add_measurement(metrics, measurement)
    metrics.average_glucose_level = MetricsHelper.add_to_average(
      average: metrics[:average_glucose_level],
      previous_count: metrics[:num_measurements],
      new_value: measurement.value)
    metrics.time_above_range = MetricsHelper.add_to_average(
      average: metrics[:time_above_range],
      previous_count: metrics[:num_measurements],
      new_value: measurement.value > HIGH_GLUCOSE_VALUE)
    metrics.time_below_range = MetricsHelper.add_to_average(
      average: metrics[:time_below_range],
      previous_count: metrics[:num_measurements],
      new_value: measurement.value < LOW_GLUCOSE_VALUE)

    metrics.num_measurements += 1
  end
end
