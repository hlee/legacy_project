class AuthController < ApplicationController
  def login
    if not request.post? then
      @user = User.new
      return
    end
    
    # POST only below
    @user = User.find_by_email(params[:user][:email])
    if @user.nil? || ! @user.password_equals?(params[:user][:password]) then
      flash[:error] = "ERROR: User not found or invalid password"
      return # rerender
    end

    self.current_user = @user
    if session[:return_to]
      # If the user was trying to access a page when they 
      # were required to login, send them back to that page
      redirect_to(session[:return_to])
      session[:return_to] = nil
    else
      redirect_to :controller => 'main', :action => 'index'
    end
  end

  def logout
    # violating REST because we do not check for POST but ... oh my
    self.current_user = nil
    
    redirect_to :controller => 'main', :action => 'index'
  end
end
