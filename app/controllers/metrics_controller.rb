class MetricsController < ApplicationController
  # @summary metrics/glucose_summary
  # Returns a summary of a member's glucose measurements for the periods preceding a
  # given timestamp.
  #
  # @parameter preceding_timestamp(query) [DateTime] The timestamp to calculate the summary for
  # @parameter user_id(query) [Integer] The id of the user to calculate the summary for
  #
  # @response Generated metrics(200)
  #   [
  #     Hash{
  #       status: String,
  #       data: Hash{
  #         week: Hash{
  #           num_measurements: Integer,
  #           average_glucose_level: Float,
  #           time_below_range: Float,
  #           time_above_range: Float
  #         },
  #         month: Hash{
  #           num_measurements: Integer,
  #           average_glucose_level: Float,
  #           time_below_range: Float,
  #           time_above_range: Float
  #         }
  #       }
  #     }
  #   ]
  #
  # @response_example (200) [Hash]
  #   {
  #     status: "success",
  #     data: {
  #       week: {
  #         num_measurements: 100,
  #         average_glucose_level: 120.5,
  #         time_below_range: 0.1,
  #         time_above_range: 0.2
  #       },
  #       month: {
  #         num_measurements: 100,
  #         average_glucose_level: 120.5,
  #         time_below_range: 0.1,
  #         time_above_range: 0.2
  #       }
  #     }
  #   }
  #
  # @response HTTP status code 202 is returned if the metrics are still being generated(202)
  #   [
  #     Hash{
  #       status: String,
  #     }
  #   ]
  # @response_example (202) [Hash]
  #   {
  #     status: "processing"
  #   }

  def glucose_summary
    Metrics::GlucoseSummary.generate_if_needed!(
      member: @member,
      preceding_timestamp: params[:preceding_timestamp].to_datetime)

    summary = Metrics::GlucoseSummary.where(
      member: @member,
      preceding_timestamp:
      params[:preceding_timestamp]).first

    if summary.nil?
      return render json: {
        status: "processing",
        params: {
          member_id: @member.id,
          preceding_timestamp: params[:preceding_timestamp]
        }
      }
    end

    render json: {
      status: "success",
      data: summary
    }
  end
end
