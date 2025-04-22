class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :find_member_profile

  private

  def find_member_profile
    if session[:member_email]
      @member = Member.find_by(email: session[:member_email])
    end
  end

  def require_login
    unless @member
      redirect_to auth_sign_in_path
    end
  end
end
