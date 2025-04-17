class HomeController < ApplicationController
  def index
    @member_data = MemberDataService.new(@member)

    respond_to do |format|
      # When we redirect, from a turbo_stream request, Turbo will pull the page
      # we redirected to with an accept: text/vnd.turbo-stream.html header. If
      # we don't specify the format here, we will render a partial instead of a
      # full page.
      format.html
    end
  end
end
