require "pry"
HIGH_VALUE = 180
LOW_VALUE = 70

class MemberDataService
  def initialize(member)
    @member = member
  end

  def glucose_metrics
    week = {
      num_measurements: 0,
      average_glucose_level: nil,
      time_below_range: nil,
      time_above_range: nil
    }

    month = {
      num_measurements: 0,
      average_glucose_level: nil,
      time_below_range: nil,
      time_above_range: nil
    }

    @member.measurements.recent.each do |measurement|
      # TODO: Handle tz_offset
      if measurement.tested_at > 1.week.ago
        week = add_glucose_measurement_to_metrics(week, measurement)
      end

      if measurement.tested_at > 1.month.ago
        month = add_glucose_measurement_to_metrics(month, measurement)
      end
    end

    {
      week: week,
      month: month
    }
  end

  private

  def add_glucose_measurement_to_metrics(metrics, measurement)
    new_metrics = {
      time_above_range: 0,
      time_below_range: 0
    }

    new_metrics[:average_glucose_level] = MetricsHelper.add_to_average(
      average: metrics[:average_glucose_level],
      previous_count: metrics[:num_measurements],
      new_value: measurement.value)
    new_metrics[:time_below_range] = MetricsHelper.add_to_average(
      average: metrics[:time_below_range],
      previous_count: metrics[:num_measurements],
      new_value: measurement.value < LOW_VALUE)
    new_metrics[:time_above_range] = MetricsHelper.add_to_average(
      average: metrics[:time_above_range],
      previous_count: metrics[:num_measurements],
      new_value: measurement.value > HIGH_VALUE)

    new_metrics[:num_measurements] = metrics[:num_measurements] + 1

    new_metrics
  end
end
