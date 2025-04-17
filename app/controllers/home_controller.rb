class HomeController < ApplicationController
  def index
    respond_to do |format|
      format.html # Render the standard HTML view with layout
      # No format.turbo_stream block here
    end
  end
end
