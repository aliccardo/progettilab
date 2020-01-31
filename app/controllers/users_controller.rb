class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy, :lock, :unlock]
  load_and_authorize_resource
  respond_to :html, only: [:index]
  respond_to :json, only: [:index, :update, :destroy]
  respond_to :js, only: [:index, :create, :update, :destroy, :lock, :unlock]

  before_action do
    add_breadcrumb "<i class='fa fa-gears'> #{I18n.t("breadcrumbs.admin.index")}</i>".html_safe, :admin_path, :title => I18n.t("breadcrumbs.admin.return")
    add_breadcrumb "<i class='fa fa-users'> #{I18n.t("breadcrumbs.admin.users.index")}</i>".html_safe, :users_path, :title => I18n.t("breadcrumbs.admin.users.return")
  end

  # GET /users
  # GET /users.json
  def index
    # @closed = params[:closed].present? ? params[:closed] : 'false'
    @users = User.enabled.where.not(username: 'system').order(:label)
    respond_to do |format|
      format.html
      format.json do
        dt_filter( @users )
      end
    end
  end

  def new
    @users = User.get_users
    @user = User.new
    if params[:modal] == "1"
      @modal = params[:modal]
      @icon = ("<i class='fa fa-plus'></i> ")
      @title = t('title', scope: 'users.new', default: 'New user')
      render layout: 'modal'
    end
    add_breadcrumb "<i class='fa fa-plus'> #{I18n.t("breadcrumbs.admin.users.new")}</i>".html_safe
  end

  def edit
    if params[:modal] == "1"
      @modal = params[:modal]
      @icon = ("<i class='fa fa-plus'></i> ")
      @title = t('title', scope: "users.edit", default: 'Edit user')
      render layout: 'modal'
    end
    add_breadcrumb "<i class='fa fa-plus'> #{I18n.t("breadcrumbs.admin.users.edit")}</i>".html_safe
  end

  def create
    @user = User.find_or_initialize_by(user_params)
    @user.locked_at = ''
    @user.author = current_user.label
    unless @user.save
      @users = User.get_users
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user.author = current_user.label
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: I18n.t('notice', scope: 'users.update', default: 'User was successfully updated.') }
        format.js
        format.json { render json: @user, status: :ok }
      else
        format.html { render :edit }
        format.js
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.author = current_user.label
    respond_to do |format|
      if @user.destroy
        format.html { redirect_to action: 'index', status: 303, notice: I18n.t('notice', scope: 'users.destroy', default: 'User was successfully deleted.') }
        format.js
        format.json { render json: @user, status: :ok }
      else
        format.html { redirect_to action: 'index', status: :unprocessable_entity }
        format.js
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def lock
    @user.author = current_user.label
    @user.destroy
  end

  def unlock
    @user.author = current_user.label
    @user.update(locked_at: :nil)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.unscoped.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:id, :username, :technic, :headtest, :chief, :supervisor, :admin)
    end
end
