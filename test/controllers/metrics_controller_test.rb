require "test_helper"

class MetricsControllerTest < ActionDispatch::IntegrationTest
  test "should get glucose_metrics" do
    MetricsHelper.add_test_data(members(:one))
    url = metrics_glucose_summary_url(member_id: members(:one).id, preceding_timestamp: "2024-04-23T23:59")

    Metrics::GlucoseSummary.create_all_for_timestamp!(
      member: members(:one),
      preceding_timestamp: "2024-04-23T23:00".to_datetime # We bin these to the top of the hour
    )

    get url

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "success", body["status"]

    # TODO(erik): It looks like the metrics for week and month are identical.
    # That's a little suspect, might be correct though. Either way, we should
    # choose a better preceding_timestamp that doesn't have this issue.
    assert_equal 228, body["data"]["week"]["num_measurements"]
    assert_equal 228, body["data"]["month"]["num_measurements"]

    assert_equal 136.78, body["data"]["week"]["average_glucose_level"].round(2)
    assert_equal 136.78, body["data"]["month"]["average_glucose_level"].round(2)

    assert_equal 0.05, body["data"]["week"]["time_below_range"].round(2)
    assert_equal 0.05, body["data"]["month"]["time_below_range"].round(2)

    assert_equal 0.18, body["data"]["week"]["time_above_range"].round(2)
    assert_equal 0.18, body["data"]["month"]["time_above_range"].round(2)
  end
end
