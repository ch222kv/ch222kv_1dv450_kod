class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user, only: [:edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    flash[:current_user] = current_user
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.is_administrator = false

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def login
    session[:return_to] ||= request.referer
  end
  def login_post
    user = User.find_by(username: params[:session][:username])
    if user.nil?
      flash[:fail] = "Could not find a user with username " + params[:session][:username]
      redirect_to login_url
    else
      user.authenticate(params[:session][:password])
      log_in user
      flash[:signed_in] = "Logged in as " + user.username
      if session[:return_to]
        flash[:notice] = "Redirecting to where you came from"
        redirect_to session.delete(:return_to)
      else
        redirect_to users_url
      end
    end
  end
  def logout_post
    log_out
    respond_to do |format|
      format.html { redirect_to :root, notice: "Logged out" }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end
    def logged_in_user
      unless logged_in?
        flash[:danger] = "Please log in. Before doing that."
        redirect_to login_url
      end
    end
    def correct_user
      if not current_user.is_administrator or  not current_user?(@user)
        flash[:notice] = "You can't edit that user"
        redirect_to :root
      end
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :password, :password_confirmation, :email)
    end
end
