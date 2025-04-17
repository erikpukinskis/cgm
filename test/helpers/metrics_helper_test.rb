require "test_helper"

class MetricHelperTest < ActiveSupport::TestCase
test "add number to nil" do
  new_average = MetricsHelper.add_to_average(average: nil, previous_count: 0, new_value: 40)
  assert_equal 40, new_average
end

  test "add number to number" do
    new_average = MetricsHelper.add_to_average(average: 2, previous_count: 1, new_value: 1)
    assert_equal 1.5, new_average
  end

  test "add true to nil" do
    new_average = MetricsHelper.add_to_average(average: nil, previous_count: 0, new_value: true)
    assert_equal 1, new_average
  end

  test "add false to nil" do
    new_average = MetricsHelper.add_to_average(average: nil, previous_count: 0, new_value: false)
    assert_equal 0, new_average
  end

  test "add true to 0 (one previous measurement)" do
    new_average = MetricsHelper.add_to_average(average: 0, previous_count: 1, new_value: true)
    assert_equal 0.5, new_average
  end

  test "add false to 0 (one previous measurement)" do
    new_average = MetricsHelper.add_to_average(average: 0, previous_count: 1, new_value: false)
    assert_equal 0, new_average
  end

  test "add true to 0 (multiple previous measurements)" do
    new_average = MetricsHelper.add_to_average(average: 0, previous_count: 3, new_value: true)
    assert_equal 0.25, new_average
  end
end
