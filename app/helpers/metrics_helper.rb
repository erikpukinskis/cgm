require "csv"

module MetricsHelper
  # Calculate the new running average of a series. Using a dynamic programming approach for speed.
  def self.add_to_average(average:, previous_count:, new_value:)
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

  def self.add_test_data(member)
    csv_path = Rails.root.join("test/fixtures/files/cgm_data_points.csv")

    CSV.foreach(csv_path, headers: true) do |row|
      tested_at = self.parse_time(row)

      if tested_at.nil?
        next
      end

      member.measurements.create(
        value: row["value"].to_i,
        tested_at: tested_at,
      )
    end
  end

  private

  def self.parse_time(row)
    # Format is "M/D/YY H:MM" + timezone separately
    # Make sure to strip quotes from timezone offset
    tz_offset = row["tz_offset"].gsub(/["“”]/, "")
    time_str = "#{row["tested_at"]} #{tz_offset}"
    DateTime.strptime(time_str, "%m/%d/%y %H:%M %z")
  rescue => e
    error_msg = "Failed to parse time: '#{time_str}' with timezone '#{tz_offset}': #{e.message}"
    raise ArgumentError, error_msg
  end
end
