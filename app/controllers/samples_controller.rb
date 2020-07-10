class SamplesController < ApplicationController
  include AttachableController
  include ImportableController
  before_action :set_user
  load_and_authorize_resource
  before_action :set_job
  before_action :set_samples
  before_action :set_sample, only: [:show, :edit, :update, :destroy]
  respond_to :html, only: [:index, :new, :edit]
  respond_to :js, only: [:new, :edit, :create, :update, :destroy]
  respond_to :json, only: [:index, :update]

  before_action do
    add_breadcrumb "<i class='fa fa-table'> #{I18n.t("breadcrumbs.jobs.all")}</i>".html_safe, :jobs_path, :title => I18n.t("breadcrumbs.jobs.return")
    add_breadcrumb "<i class='fa fa-edit text-trim'> #{@job.title}</i>".html_safe, edit_job_path(id: @job.id), :title => I18n.t("breadcrumbs.jobs.edit")
    add_breadcrumb "<i class='fa fa-table'> #{I18n.t("breadcrumbs.samples.all")}</i>".html_safe, :job_samples_path, :title => I18n.t("breadcrumbs.samples.return")
  end
  # GET /samples
  # GET /samples.json
  def index
    @section = 'samples'
    @modal = params[:modal]
    respond_to do |format|
      format.html do
        @samples = @samples.page( params[:page] )
        if params[:modal] == "1"
          @samples = @samples.per(5)
          @modal = params[:modal]
          @title = @job.title
          @icon = ("<i class='fa fa-eye'></i> <span id='title-label'>#{@job.code}</span>").html_safe
          @menu = [
            {fa: 'list', text: t('details', scope: 'jobs', default: 'Details'), to: job_path(id: @job.id, section: 'details', modal: @modal), remote: true},
            {fa: 'fax', text: t('contacts', scope: 'jobs', default: 'Contacts'), to: job_path(id: @job.id, section: 'contacts', modal: @modal), remote: true},
            {fa: 'calendar', text: t('title', scope: 'timetables', default: 'Timetables'), to: job_timetables_path(job_id: @job.id, modal: @modal), remote: true},
            {fa: 'flask', text: t('title', scope: 'samples', default: 'Timetables'), to: job_samples_path(job_id: @job.id, modal: @modal), remote: true, class: 'selected'},
          ]
          @edit = ( {fa: 'edit', to: edit_job_path(id: @job.id), remote: false, confirm: 'Sei sicuro di voler modificare questi dati?' } if can?(:update, @job) )
          render layout: 'modal'
        end
      end
      format.js
      format.json do
        @samples = @samples.left_outer_joins(:type_matrix).left_outer_joins(:analisies)
        dt_filter( @samples )
      end
    end
  end

  # GET /samples/1
  # GET /samples/1.json
  def show
    @modal = params[:modal]
    @draw = params[:draw] || 1
    respond_to do |format|
      format.html do
        if params[:modal] == "1"
          @modal = params[:modal]
          @icon = ("<i class='fa fa-eye'></i> ")
          @title = "#{t('title', scope: 'samples.show', default: 'Show')}"
          render layout: 'modal'
        end
        add_breadcrumb "<i class='fa fa-table'> #{I18n.t("breadcrumbs.samples.show")}</i>".html_safe
      end
      format.js
      format.json { render 'show_by_sample' }
    end
  end

  # GET /samples/new
  def new
    @sample = @job.samples.new(sample_params)
    @users = User.all.select(:id, :label).pluck(:label, :id)
    @analisy_types = AnalisyType.all.pluck(:title, :id)
    @categories = MatrixType.categories
    # @matrices = :nil #MatrixType.all
    if params[:modal] == "1"
      @modal = params[:modal]
      @rid = params[:rid]
      @icon = ("<i class='fa fa-cube'></i> ")
      @title = t('title', scope: 'samples.new', default: 'New sample')
      render layout: 'modal'
    end
    add_breadcrumb "<i class='fa fa-table'> #{I18n.t("breadcrumbs.samples.new")}</i>".html_safe
  end

  # GET /samples/1/edit
  def edit
    @users = User.all.select(:id, :label).pluck(:label, :id)
    @analisy_types = AnalisyType.all.pluck(:title, :id)
    @analisies = @sample.analisies
    @categories = MatrixType.categories
    @matrices = @sample.type_matrix.blank? ? MatrixType.matrices : MatrixType.matrices.where(pid: @sample.type_matrix.pid)
    @sample.category_id = @sample.type_matrix.pid unless @sample.type_matrix.blank?
    if params[:modal] == "1"
      @modal = params[:modal]
      @icon = ("<i class='fa fa-cube'></i> ")
      @title = "#{t('title', scope: 'samples.edit', default: 'Edit sample')} #{@sample.code}"
      render layout: 'modal'
    end
    add_breadcrumb "<i class='fa fa-table'> #{I18n.t("breadcrumbs.samples.edit")}</i>".html_safe
  end

  # POST /samples
  # POST /samples.json
  def create
    @sample = @job.samples.new(sample_params) do |s|
      s.analisies.each { |a| a.reference_at ||= s.stop_at }
    end
    @sample.author = current_user.label unless @sample.author.blank?
    @sample.created_by = current_user.label
    @sample.updated_by = current_user.label
    @users = User.all.select(:id, :label).pluck(:label, :id)
    @analisy_types = AnalisyType.all.pluck(:title, :id)
    @analisies = @sample.analisies
    @categories = MatrixType.categories
    @matrices = MatrixType.all if @sample.type_matrix_id.present?
    @sample.category_id = @sample.type_matrix.pid unless @sample.type_matrix.blank?
    respond_to do |format|
      if @sample.save
        format.html { redirect_to job_samples_path(job_id: @job.id), notice: I18n.t('notice', scope: 'samples.create', default: 'Sample was successfully created.') }
        format.js
        format.json { render :show, status: :created, location: @sample }
      else
        puts @sample.errors.full_messages.join(', ')
        format.html { render :new }
        format.js
        format.json { render json: @sample.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /samples/1
  # PATCH/PUT /samples/1.json
  def update
    @sample.author = current_user.label
    @sample.updated_by = current_user.label
    @modal = params[:modal]
    @users = User.all.select(:id, :label).pluck(:label, :id)
    @categories = MatrixType.categories
    @matrices = MatrixType.all
    @modal = params[:modal]
    respond_to do |format|
      if @sample.update_attributes(sample_params)
        format.html { redirect_to job_samples_path(job_id: @job.id), notice: I18n.t('notice', scope: 'samples.update', default: 'Sample was successfully updated.') }
        format.js
        format.json { render :show, status: :created, location: @sample }
      else
        format.html{ render :edit }
        format.js
        format.json { render json: @sample.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /samples/1
  # DELETE /samples/1.json
  def destroy
    @sample.author = current_user.label
    @sample.destroy
    @samples = @job.samples
    respond_to do |format|
      format.html { redirect_to job_samples_path(job_id: @job.id), notice: I18n.t('notice', scope: 'samples.destroy', default: 'Sample was successfully destroyed.') }
      format.js
      format.json { head :no_content }
    end
  end

  private
    def set_user
      @user = current_user
    end

    def set_job
      @job = Job.find(params[:job_id])
    end

    def set_samples
      @samples = @job.samples.distinct
    end

    def set_sample
      @sample = @samples.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sample_params
      params.fetch(:sample, {}).permit(:id, :job_id, :timetable_id, :device, :client_code, :author_id, :code, :accepted_at, :report, :cod_sample_client, :start_at, :stop_at, :reference_at, :latitude, :longitude, :category_id, :type_matrix_id, :conservation, :body, :author, :skip_presence, analisies_attributes: [ :id, :code, :sample_id, :analisy_type_id, :date_at, :reference_at, :method, :body, :author, :done, :_destroy, :skip_validate, analisy_chiefs_attributes: [ :id, :user_id ], analisy_headtests_attributes: [ :id, :user_id ], analisy_technic_user_ids: [], nuclide_ids: []  ]  )
    end
end
