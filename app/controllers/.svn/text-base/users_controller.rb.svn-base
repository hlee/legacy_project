class UsersController < ApplicationController
  def user_list
      respond_to do |format|
        format.xml { render :xml => User.find(:all)}
      end
  end
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
 #   @user_pages, @users = paginate :users, :per_page => 2
     @users = User.paginate :page => params[:page]||1, :per_page => 10 
 end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new
    @user.email = params[:user][:email]
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'roles', :id => @user.id
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    @user.password = 'filtered'
  end

  def roles
    @user = User.find(params[:id])
    @user.password = 'filtered'
  end

  def permissions
    @user = User.find(params[:id])
    user_admin_role = Role.find_by_display_name("User Admin")
    if @user.has_role?(user_admin_role.identifier) && !params[:checkbox].has_key?(user_admin_role.id)
      # The user is currently a user_admin, make sure there are
      # other user_admins available
      unless User.find(:all).find_all{|user| user.has_role?(user_admin_role.identifier)}.length >= 2
        flash[:error] = "You can not remove user admin from last user_admin user, other changes made"
        params[:checkbox][user_admin_role.id.to_s] = "1"
      end
    end
    @user.roles = []
    params[:checkbox].each {|permission, value|
      @user.roles << Role.find(permission) if value.eql?("1")
    }
    if @user.save!
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'roles'
    end
	end

  def update
    @user = User.find(params[:id])
    @user.email = params[:user][:email]
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit', :id => @user.id
    end
  end

  def destroy
    user = User.find(params[:id])
    unless user.destroy
      flash[:error] = user.errors.full_messages
    end
    redirect_to :action => 'list'
  end
end
