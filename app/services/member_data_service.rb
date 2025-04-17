HIGH_VALUE = 180
LOW_VALUE = 70

class MemberDataService
  def initialize(member)
    @member = member
  end

  def glucose_metrics
    week = {
      measurements: 0,
      average_glucose_level: nil,
      time_below_range: nil,
      time_above_range: nil
    }

    month = {
      measurements: 0,
      average_glucose_level: nil,
      time_below_range: nil,
      time_above_range: nil
    }

    @member.measurements.recent.each do |measurement|
      # TODO: Handle tz_offset
      if measurement.tested_at > 1.week.ago
        new_measurements = week[:measurements] + 1
        week[:average_glucose_level] = ((week[:average_glucose_level] || 0 * week[:measurements]) + measurement.value) / new_measurements
      end
    end

    {
      week: week,
      month: month
    }
  end
end
