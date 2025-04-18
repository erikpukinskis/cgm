require "pry"
HIGH_VALUE = 180
LOW_VALUE = 70

class MemberDataService
  def initialize(member:, current_time:)
    puts "current_time: #{current_time}"
    @member = member
    @current_time = current_time
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

    start_of_last_7 = @current_time.beginning_of_day - 6.days
    start_of_month = @current_time.beginning_of_month

    @member.measurements.between(start_time: start_of_month, end_time: @current_time).each do |measurement|
      if measurement.tested_at > @current_time
        raise "measurement was in the future?"
      end

      if measurement.tested_at > start_of_last_7
        puts "measurement.tested_at: #{measurement.tested_at} is in last 7: #{start_of_last_7}"
        week = add_glucose_measurement_to_metrics(week, measurement)
      end

      if measurement.tested_at > start_of_month
        puts "measurement.tested_at: #{measurement.tested_at} is in month: #{start_of_month}"
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
