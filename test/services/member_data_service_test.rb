require "test_helper"

class MemberDataServiceTest < ActiveSupport::TestCase
  test "returns nil if no measurements" do
    member = members(:one)
    metrics = MemberDataService.new(member).glucose_metrics

    assert_equal({
      num_measurements: 0,
      average_glucose_level: nil,
      time_below_range: nil,
      time_above_range: nil
    }, metrics[:week])
  end

  test "returns average, time below, and time above if there is one recent measurement" do
    member = members(:one)
    member.measurements.create!(value: 40, tested_at: 1.day.ago, tz_offset: "+06:00")
    metrics = MemberDataService.new(member).glucose_metrics

    assert_equal({
      num_measurements: 1,
      average_glucose_level: 40,
      time_below_range: 1.0,
      time_above_range: 0
    }, metrics[:week])
  end

  test "excludes measurements older than 1 week" do
    member = members(:one)
    member.measurements.create!(value: 40, tested_at: 8.days.ago, tz_offset: "+06:00")
    metrics = MemberDataService.new(member).glucose_metrics

    assert_equal({
      num_measurements: 0,
      average_glucose_level: nil,
      time_below_range: nil,
      time_above_range: nil
    }, metrics[:week])
  end

  test "averages across multiple measurements" do
    member = members(:one)
    member.measurements.create!(value: 40, tested_at: 1.day.ago, tz_offset: "+06:00")
    member.measurements.create!(value: 100, tested_at: 2.days.ago, tz_offset: "+06:00")
    member.measurements.create!(value: 190, tested_at: 10.days.ago, tz_offset: "+06:00")
    member.measurements.create!(value: 170, tested_at: 10.days.ago, tz_offset: "+06:00")
    metrics = MemberDataService.new(member).glucose_metrics

    assert_equal({
      num_measurements: 2,
      average_glucose_level: 70,
      time_below_range: 0.5,
      time_above_range: 0
    }, metrics[:week])

    assert_equal({
      num_measurements: 4,
      average_glucose_level: 125,
      time_below_range: 0.25,
      time_above_range: 0.25
    }, metrics[:month])
  end
end
