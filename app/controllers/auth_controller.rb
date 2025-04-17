class AuthController < ApplicationController
  def join_form
    @member = Member.new
  end

  def join
    @member = Member.new(member_params)

    if @member.save
      session[:member_id] = @member.id
      flash[:notice] = "Welcome! Your account has been created."
      redirect_to root_path, status: :see_other
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "join_form_container",
            template: "auth/join_form"
          ), status: :unprocessable_entity
        end
        format.html { render :join_form, status: :unprocessable_entity }
      end
    end
  end

  def sign_in_form
  end

  private

  def member_params
    params.require(:member).permit(:email, :password, :password_confirmation)
  end
end
