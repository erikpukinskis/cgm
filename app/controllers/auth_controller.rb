class AuthController < ApplicationController
  def join_form
    @member = Member.new
  end

  def join
    @member = Member.new(member_params)

    if @member.save
      sign_in_member(@member)

      flash[:notice] = "Welcome! Your account has been created."
      redirect_to root_path, status: :see_other
    else
      render turbo_stream: turbo_stream.replace(
        "join_form_container",
        template: "auth/join_form"
      ), status: :unprocessable_entity
    end
  end

  def sign_in_form
  end

  def sign_in
    @member = Member.find_by(email: params[:email])

    if @member && @member.authenticate(params[:password])
      sign_in_member(@member)
      redirect_to root_path, status: :see_other
    else
      flash[:error] = "Invalid email or password"
      redirect_to auth_sign_in_path, status: :unprocessable_entity
    end
  end

  def sign_out
    session.delete(:member_id)
    session.delete(:member_email)
    redirect_to root_path
  end

  private

  def member_params
    params.require(:member).permit(:email, :password, :password_confirmation)
  end

  def sign_in_member(member)
    session[:member_id] = @member.id
    session[:member_email] = @member.email
  end
end
