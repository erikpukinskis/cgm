class DashboardsController < ApplicationController
  # TODO(erik): YARD comments explaining relationship to metric#glucose_summary action
  def glucose_metrics
    metrics = Metrics::GlucoseSummary.find_or_queue(
      member: @member,
      preceding_timestamp: params[:preceding_timestamp] ? DateTime.parse(params[:preceding_timestamp]) : DateTime.now
    )

    respond_to do |format|
      format.html do
        render partial: "dashboards/glucose_metrics", locals: {
          metrics: metrics,
          preceding_timestamp: params[:preceding_timestamp] }
      end
    end
  end
end
