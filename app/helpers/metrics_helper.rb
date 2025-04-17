class MetricsHelper
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
end
