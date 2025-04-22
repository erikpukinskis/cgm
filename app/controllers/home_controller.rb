# typed: true

class HomeController < ApplicationController
  before_action :require_login

  def index
    @preceding_timestamp = params[:mock_time] ? params[:mock_time].to_datetime : DateTime.now.beginning_of_hour
    @glucose_metrics = Metrics::GlucoseSummary.find_or_queue(
      member: @member,
      preceding_timestamp: @preceding_timestamp
    )

    respond_to do |format|
      # When we redirect, from a turbo_stream request, Turbo will pull the page
      # we redirected to with an accept: text/vnd.turbo-stream.html header. If
      # we don't specify the format here, we will render a partial instead of a
      # full page.
      format.html
    end
  end
end
