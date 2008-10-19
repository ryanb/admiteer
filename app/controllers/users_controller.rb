class UsersController < ApplicationController
  before_filter :login_required, :only => :show

  def new
    @user = User.new
    if session[:openid_attributes]
      @user.login = session[:openid_attributes]['nickname']
      @user.email = session[:openid_attributes]['email']
      @user.full_name = session[:openid_attributes]['fullname']
      @user.identity_url = session[:openid_attributes]['openid_url']
      session[:openid_attributes] = nil
    end
  end

  def create
    @user = User.new(params[:user])
    @user.save!
    self.current_user = @user
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  # the below actions should probably go in a separate controller
  # since it is a singular resource...
  def show
    @user = current_user
  end
  
  def edit
    @user = current_user
  end
  
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to dashboard_path
    else
      render :action => 'edit'
    end
  end
end
