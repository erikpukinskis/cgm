require "test_helper"

class Metrics::GlucoseSummaryTest < ActiveSupport::TestCase
  test "returns nil if no measurements" do
    member = members(:one)
    metrics = Metrics::GlucoseSummary.create_all_for_timestamp!(member: member, preceding_timestamp: DateTime.now)

    assert_model_attributes(metrics[:week], {
      num_measurements: 0,
      average_glucose_level: nil,
      time_below_range: nil,
      time_above_range: nil
    })
  end

  # TODO(erik): I wonder if we need some more careful tests here for the week/month
  # start times, especially if we care about timezones.

  test "returns average, time below, and time above if there is one recent measurement" do
    member = members(:one)
    # TODO(erik): This 1.day.ago thing works, but I would be a little concerned
    # about how it behaves near midnight. I would prefer to mock the clock and
    # use specific timetamps.
    member.measurements.create!(value: 40, tested_at: 1.day.ago)
    metrics = Metrics::GlucoseSummary.create_all_for_timestamp!(member: member, preceding_timestamp: DateTime.now)

    assert_model_attributes(metrics[:week], {
      num_measurements: 1,
      average_glucose_level: 40,
      time_below_range: 1.0,
      time_above_range: 0
    })
  end

  test "excludes measurements older than 1 week" do
    member = members(:one)
    member.measurements.create!(value: 40, tested_at: 8.days.ago)
    metrics = Metrics::GlucoseSummary.create_all_for_timestamp!(member: member, preceding_timestamp: DateTime.now)

    assert_model_attributes(metrics[:week], {
      num_measurements: 0,
      average_glucose_level: nil,
      time_below_range: nil,
      time_above_range: nil
    })
  end

  test "averages across multiple measurements" do
    member = members(:one)
    member.measurements.create!(value: 40, tested_at: 1.day.ago)
    member.measurements.create!(value: 100, tested_at: 2.days.ago)
    member.measurements.create!(value: 190, tested_at: 10.days.ago)
    member.measurements.create!(value: 170, tested_at: 10.days.ago)
    metrics = Metrics::GlucoseSummary.create_all_for_timestamp!(member: member, preceding_timestamp: DateTime.now)

    assert_model_attributes(metrics[:week], {
      num_measurements: 2,
      average_glucose_level: 70,
      time_below_range: 0.5,
      time_above_range: 0
    })

    assert_model_attributes(metrics[:month], {
      num_measurements: 4,
      average_glucose_level: 125,
      time_below_range: 0.25,
      time_above_range: 0.25
    })
  end
end
