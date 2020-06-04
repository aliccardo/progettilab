class AnalisiesController < ApplicationController
  load_and_authorize_resource
  #load_resource :analisy_reports
  before_action :set_user
  before_action :set_job
  before_action :set_sample, except: [:import, :imported, :download_template ]
  before_action :set_analisies, except: [:import, :imported, :download_template ]
  before_action :set_analisy, only: [:show, :edit, :update, :destroy, :results, :report, :delete_report]
  respond_to :html, only: [:index, :new, :edit, :report]
  respond_to :js, only: [:new, :edit, :create, :update, :destroy]
  respond_to :json, only: [:update]
  respond_to :pdf, only: [:report]

  before_action do
    add_breadcrumb "<i class='fa fa-table'> #{I18n.t("breadcrumbs.jobs.all")}</i>".html_safe, :jobs_path, :title => I18n.t("breadcrumbs.jobs.return")
    add_breadcrumb "<i class='fa fa-edit text-trim'> #{@job.title}</i>".html_safe, edit_job_path(id: @job.id), :title => I18n.t("breadcrumbs.jobs.edit")
    add_breadcrumb "<i class='fa fa-edit'>Campione #{@sample.code}</i>".html_safe, edit_job_sample_path(job_id:@job.id, id: @job.id), :title => I18n.t("breadcrumbs.samples.edit")
    add_breadcrumb "<i class='fa fa-table'> #{I18n.t("breadcrumbs.analisies.all")}</i>".html_safe, :job_sample_analisies_path, :title => I18n.t("breadcrumbs.analisies.return")
  end

  # GET /analisies
  # GET /analisies.json
  def index
    @section = 'analisies'
    @modal = params[:modal]
    respond_to do |format|
      format.html do
        if params[:modal] == "1"
          @analisies = @analisies.page( params[:page] ).per(5)
          @icon = ("<i class='fa fa-eyw'></i> ")
          @title = "#{t('show', scope: '', default: 'Show')}"
          render layout: 'modal'
        else
          @analisies = @analisies.page params[:page]
        end
      end
      format.js
      format.json do
        @analisies = @analisies.joins(:sample).joins(:type)
        dt_filter( @analisies )
      end
    end
  end

  # GET /analisies/1
  # GET /analisies/1.json
  def show
    @modal = params[:modal]
    respond_to do |format|
      format.html do
        if params[:modal] == "1"
          @modal = params[:modal]
          @icon = ("<i class='fa fa-eyw'></i> ")
          @title = "#{t('title', scope: 'analisies.show', default: 'Show')}"
          render layout: 'modal'
        end
        add_breadcrumb "<i class='fa fa-wpform'> #{I18n.t("breadcrumbs.analisies.show")}</i>".html_safe
      end
      format.js
    end
  end

  # GET /analisies/new
  def new
    @analisy = @analisies.new
    @analisy.analisy_chiefs.build
    @analisy.analisy_headtests.build
    @analisy.analisy_technics.build
    @analisy.results.build
    @units = Unit.select(:id, :title)
    respond_to do |format|
      format.html do
        if params[:modal] == "1"
          @modal = params[:modal]
          @icon = ("<i class='fa fa-plus'></i><i class='fa fa-flask'></i> ")
          @title = "#{t('title', scope: 'analisies.new', default: 'New analisy')}"
          render layout: 'modal'
        end
        add_breadcrumb "<i class='fa fa-plus'> #{I18n.t("breadcrumbs.analisies.new")}</i>".html_safe
      end
      format.js
    end
  end

  # GET /analisies/1/edit
  def edit
    @analisy.analisy_chiefs.build if @analisy.analisy_chiefs.blank?
    @analisy.analisy_headtests.build if @analisy.analisy_headtests.blank?
    @analisy.analisy_technics.build if @analisy.analisy_technics.blank?
    @analisy_types = @sample.analisies.map{ |a| [ a.type.title, a.type.id ] }
    @units = Unit.select(:id, :title)
    if params[:modal] == "1"
      @modal = params[:modal]
      @icon = ("<i class='fa fa-edit'></i><i class='fa fa-flask'></i> ")
      @title = "#{t('title', scope: 'analisies.edit', default: 'Edit analisy')} #{@analisy.code}"
      render layout: 'modal'
    end
    add_breadcrumb "<i class='fa fa-edit'>Analisi #{@analisy.code}</i>".html_safe
  end

  # POST /analisies
  # POST /analisies.json
  def create
    @analisy = @analisies.new(analisy_params)
    @analisy.author = current_user.label
    respond_to do |format|
      if @analisy.save
        @samples = @job.samples
        @units = Unit.select(:id, :title)
        format.html { redirect_to @analisy, notice: I18n.t('notice', scope: 'analisies.create', default: 'Analisy was successfully created.') }
        format.js
        format.json { render :show, status: :created, location: @analisy }
      else
        @units = Unit.select(:id, :title)
        format.html { render :new }
        format.js { render :new }
        format.json { render json: @analisy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /analisies/1
  # PATCH/PUT /analisies/1.json
  def update
    @analisy.author = current_user.label
    skip = params[:skip_validate]
    @analisy.skip_validate = skip unless skip.blank?
    @modal = params[:modal]
    @analisy_types = @sample.analisies.map{ |a| [ a.type.title, a.type.id ] }
    respond_to do |format|
      if @analisy.update(analisy_params)
        @samples = @job.samples
        @units = Unit.select(:id, :title)
        format.html { redirect_to job_sample_analisy_path(job_id: @analisy.job.id, sample_id: @analisy.sample.id, id: @analisy.id), notice: I18n.t('notice', scope: 'analisies.update', default: 'Analisy was successfully updated.') }
        format.js
        format.json { render :show, status: :ok, location: job_sample_analisy_path(job_id: @analisy.job.id, sample_id: @analisy.sample.id, id: @analisy.id) }
      else
        puts @analisy.errors.full_messages.join(', ')
        @analisy.analisy_chiefs.build if @analisy.analisy_chiefs.blank?
        @analisy.analisy_headtests.build if @analisy.analisy_headtests.blank?
        @analisy.analisy_technics.build if @analisy.analisy_technics.blank?
        @analisy_types = @sample.analisies.map{ |a| [ a.type.title, a.type.id ] }
        @units = Unit.select(:id, :title)
        format.html { render :edit }
        format.js
        format.json { render json: @analisy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /analisies/1
  # DELETE /analisies/1.json
  def destroy
    @analisy.author = current_user.label
    if @analisy.destroy
      @samples = @job.samples
      @analisies = @job.analisies
      respond_to do |format|
        format.html { redirect_to job_samples_path(job_id: @job.id, section: 'analisies') , notice: I18n.t('notice', scope: 'analisies.destroy', default: 'Analisy was successfully destroyed.') }
        format.js
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html
        format.js
        format.json { head :no_content }
      end
    end
  end

  def results
    respond_to do |format|
      format.html do
        @analisy.results.build if @analisy.results.blank?
        add_breadcrumb "<i class='fa fa-list'> #{I18n.t("breadcrumbs.analisies.results")}</i>".html_safe
      end
      format.js do
        @analisy.update(analisy_params) unless params[:analisy].blank?
      end
    end
  end

  private
    def set_user
      @user = current_user
    end

    def set_job
      @job = Job.find(params[:job_id])
    end

    def set_sample
      @sample = @job.samples.find(params[:sample_id])
    end

    def set_analisies
      @analisies = @sample.analisies
    end

    def set_analisy
      @analisy = @analisies.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def analisy_params
      params.require(:analisy).permit(:id, :code, :analisy_type_id, :date_at, :reference_at, :method, :results, :body, :skip_validate, :analisy_chief_user_ids, :analisy_headtest_user_ids, analisy_chiefs_attributes: [ :id, :analisy_id, :user_id, :role ], analisy_headtests_attributes: [ :id, :analisy_id, :role, :user_id ], analisy_technics_attributes: [ :id, :analisy_id, :role, :user_id ], analisy_technic_user_ids: [], results_attributes: [ :id, :nuclide_id, :result, :result_unit_id, :symbol, :indecision, :indecision_unit_id, :absence_analysis, :mcr, :mcr_unit_id, :active, :_destroy ], attachments_attributes: [ :title, :body, :category, :file ])
    end

end
