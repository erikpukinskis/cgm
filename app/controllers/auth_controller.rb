class AuthController < ApplicationController
  def join_form
    @member = Member.new
  end

  def join
    @member = Member.new(member_params)

    if @member.save
      session[:member_id] = @member.id
      redirect_to root_path, notice: "Welcome! Your account has been created."
    else
      render status: :unprocessable_entity
    end
  end

  def sign_in_form
  end

  private

  def member_params
    params.require(:member).permit(:email, :password, :password_confirmation)
  end
end
