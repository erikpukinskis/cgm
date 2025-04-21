# typed: strict

HIGH_VALUE = 180
LOW_VALUE = 70

class MemberDataService
  extend T::Sig

  sig { params(member: Member, current_time: DateTime).void }
  def initialize(member:, current_time: DateTime.now)
    @member = member
    @current_time = current_time
  end

  GlucoseMetricsType = T.type_alias do
    {
      num_measurements: Integer,
      average_glucose_level: T.nilable(Float),
      time_below_range: T.nilable(Float),
      time_above_range: T.nilable(Float)
    }
  end

  MetricsType = T.type_alias do
    {
      week: GlucoseMetricsType,
      month: GlucoseMetricsType
    }
  end

  sig { returns(MetricsType) }
  def glucose_metrics
    week = T.let({
      num_measurements: 0,
      average_glucose_level: nil,
      time_below_range: nil,
      time_above_range: nil
    }, GlucoseMetricsType)

    month = T.let({
      num_measurements: 0,
      average_glucose_level: nil,
      time_below_range: nil,
      time_above_range: nil
    }, GlucoseMetricsType)

    start_of_last_7 = @current_time.beginning_of_day - 6.days
    start_of_month = @current_time.beginning_of_month

    @member.measurements.between(start_time: start_of_month, end_time: @current_time).each do |measurement|
      if measurement.tested_at > @current_time
        raise "measurement was in the future?"
      end

      if measurement.tested_at > start_of_last_7
        week = add_glucose_measurement_to_metrics(week, measurement)
      end

      if measurement.tested_at > start_of_month
        month = add_glucose_measurement_to_metrics(month, measurement)
      end

      if measurement.tested_at < start_of_month
        raise "measurement was before the query start time?"
      end
    end

    {
      week: week,
      month: month
    }
  end

  private

  sig { params(metrics: GlucoseMetricsType, measurement: Measurement).returns(GlucoseMetricsType) }
  def add_glucose_measurement_to_metrics(metrics, measurement)
    {
      num_measurements: metrics[:num_measurements] + 1,
      average_glucose_level: MetricsHelper.add_to_average(
        average: metrics[:average_glucose_level],
        previous_count: metrics[:num_measurements],
        new_value: measurement.value),
      time_above_range: MetricsHelper.add_to_average(
        average: metrics[:time_above_range],
        previous_count: metrics[:num_measurements],
        new_value: measurement.value > HIGH_VALUE),
      time_below_range: MetricsHelper.add_to_average(
        average: metrics[:time_below_range],
        previous_count: metrics[:num_measurements],
        new_value: measurement.value < LOW_VALUE)
    }
  end
end
