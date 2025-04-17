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

    if measurement.value < LOW_VALUE
      new_metrics[:time_below_range] = add_to_time(metrics[:time_below_range], metrics[:num_measurements])
    elsif measurement.value > HIGH_VALUE
      new_metrics[:time_above_range] = add_to_time(week[:time_above_range], metrics[:num_measurements])
    end

    new_metrics[:num_measurements] = metrics[:num_measurements] + 1

    new_metrics
  end

  def add_to_average(average, previous_count, new_value)
    previous_average = average || 0
    new_count = previous_count + 1
    new_average = previous_average * previous_count + new_value / new_count

    new_average
  end

  def add_to_time(percent_of_time, previous_count)
    previous_days = (percent_of_time || 0) * previous_count
    new_days = previous_days + 1
    new_count = previous_count + 1
    new_percent = new_days / new_count

    new_percent
  end
end
