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

    new_metrics[:average_glucose_level] = add_to_average(metrics[:average_glucose_level], metrics[:num_measurements], measurement.value)
    new_metrics[:time_below_range] = add_to_average(metrics[:time_below_range], metrics[:num_measurements], measurement.value < LOW_VALUE)
    new_metrics[:time_above_range] = add_to_average(metrics[:time_above_range], metrics[:num_measurements], measurement.value > HIGH_VALUE)

    new_metrics[:num_measurements] = metrics[:num_measurements] + 1

    new_metrics
  end

  def add_to_average(average, previous_count, new_value)
    if new_value == true
      new_value = 1.0
    elsif new_value == false
      new_value = 0.0
    end

    previous_average = average ? average.to_f : 0.0
    new_count = previous_count + 1
    new_average = (previous_average * previous_count + new_value) / new_count

    new_average
  end
end
