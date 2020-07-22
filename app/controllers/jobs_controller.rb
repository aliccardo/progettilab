class JobsController < ApplicationController
  include AttachableController
  load_resource
  before_action :set_user
  before_action :search_params, except: [:new, :create, :update, :destroy, :print]
  before_action :set_jobs, except: [:index, :new, :create, :update, :destroy]
  before_action :set_job, only: [:show, :edit, :update, :destroy, :print, :logs, :reports, :create_multiple_reports, :destroy_multiple_reports, :reopen, :download]
  before_action :set_role, only: [:show, :edit, :update, :destroy, :print]
  respond_to :html, only: [:index, :show, :new, :edit, :print, :logs, :reopen, :deleted, :reports]
  respond_to :js, only: [:create, :update, :destroy, :reopen]
  respond_to :json, only: [:index, :show, :logs, :reports]
  respond_to :pdf, only: [:printed]

  before_action do
    add_breadcrumb "<i class='fa fa-briefcase'> #{I18n.t("breadcrumbs.jobs.all")}</i>".html_safe, :jobs_path, :title => I18n.t("breadcrumbs.jobs.return")
  end
  # GET /jobs
  # GET /jobs.json
  def index
    respond_to do |format|
      format.html
      format.json do
        dt_filter( @jobs )
      end
    end
  end

  def search
    if params[:modal] == "1"
      @modal = params[:modal]
      @icon = ("<i class='fa fa-search'></i> ")
      @title = "#{t('filter', scope: '', default: 'Filter')}"
      @other = "<span id='jobs_count'></span>"
      render layout: 'modal'
    end
  end

  def searched
  end

  def download
    attachment_download
  end

  def analisies
    @analisies = @job.analisies
    respond_to do |format|
      format.html do
        add_breadcrumb "<i class='fa fa-edit'> #{@job.title}</i>".html_safe, edit_job_path(id: @job.id), :title => I18n.t("breadcrumbs.samples.edit")
        add_breadcrumb "<i class='fa fa-table'> #{I18n.t("breadcrumbs.analisies.all")}</i>".html_safe
      end
      format.js
      format.json do
        @analisies = @analisies.joins(:sample).joins(:type)
        dt_filter( @analisies )
      end
    end
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
    @section = params[:section] || 'details'
    @users = User.select(:id, :label)
    @chiefs = @users.chiefs
    @managers = @job.job_managers
    @technicians = @job.job_technicians
    if params[:modal] == "1"
      @modal = params[:modal]
      @title = @job.title
      @icon = ("<i class='fa fa-hashtag'></i> <span id='title-label'>#{@job.code}</span>").html_safe
      @menu = [
        {fa: 'file', text: t('details', scope: 'jobs', default: 'Details'), to: job_path(@job, modal: @modal), remote: true},
        {fa: 'table', text: t('title', scope: 'timetables', default: 'Timetables'), to: job_timetables_path(job_id: @job.id, modal: @modal), remote: true},
        {fa: 'table', text: t('title', scope: 'samples', default: 'Samples'), to: job_samples_path(job_id: @job.id, modal: @modal), remote: true},
        {fa: 'table', text: t('title', scope: 'analisies', default: 'Analisies'), to: job_analisies_path(job_id: @job.id, modal: @modal), remote: true},
        {fa: 'table', text: t('issued', scope: 'topbar.reports', default: 'Reports'), to: job_reports_path(job_id: @job.id, modal: @modal), remote: true},
        ( {fa: 'edit', title: t('title', scope: 'jobs.edit', default: 'Edit jobs'), to: edit_job_path(id: @job.id) } if can?( :update, @job ) ),
        ( {fa: 'external-link', title: t('title', scope: 'jobs.show', default: 'View details of jobs'), to: job_path(id: @job.id) } if cannot?( :update, @job ) && can?( :read, @job ) ),
      ]
      render layout: 'modal'
    end
    add_breadcrumb "<i class='fa fa-form'> #{I18n.t("breadcrumbs.jobs.show")}</i>".html_safe
  end

  # GET /jobs/new
  def new
    @managers = User.select(:id, :label).enabled.pluck(:label, :id)
    @chiefs = User.chiefs.select(:id, :label).enabled.pluck(:label, :id)
    @job = Job.new(author: @user)
    add_breadcrumb "<i class='fa fa-plus'> #{I18n.t("breadcrumbs.jobs.new")}</i>".html_safe
  end

  def create
    @job = Job.new(job_params)
    @job.author = current_user.label
    if @job.save
      # Invio e-mail Responsabili proc/att per avvisare della creazione del nuovo proc/att e del fatto di esssere stati indicati come Responsabili
      @job.job_managers.each do |manager|
        unless manager.email.blank?
          JobMailer.create(@job, manager, author: current_user, role: 'manager').deliver_now
        end
      end
      redirect_to edit_job_path(@job), notice: I18n.t('notice', scope: 'jobs.create', default: 'Job was successfully created.')
    else
      @managers = User.pluck(:label, :id)
      @chiefs = User.chiefs.pluck(:label, :id)
      render :new
    end
  end

  # GET /jobs/1/edit
  def edit
    @section = params[:section] || 'details'
    @users = User.select(:id, :label)
    @chiefs = @users.chiefs
    @managers = @users
    @technicians = @users
    @analisy_types = AnalisyType.all.pluck(:title, :id)
    @job.contacts.build if @job.contacts.blank?
    add_breadcrumb "<i class='fa fa-edit text-trim'> #{ @job.title }</i>".html_safe, edit_job_path(id: @job.id), :title => I18n.t("breadcrumbs.jobs.edit")
    add_breadcrumb I18n.t("breadcrumbs.jobs.sections.#{ @section }")
  end

  def update
    @job.author = current_user.label
    @section = params[:section] || 'details'
    @users = User.select(:id, :label)
    chief_before = @job.chief_id
    managers_before = @job.job_manager_ids
    technicians_before = @job.job_technician_ids
    closed_was = @job.closed?
    respond_to do |format|
      begin
        @job.assign_attributes(job_params)
      rescue ActiveRecord::RecordInvalid => invalid
        @errors = invalid.record.errors.full_messages.to_sentence
      rescue PG::UniqueViolation => invalid
        @errors = invalid.record.errors.full_messages.to_sentence
      end

      if @job.save
        if @job.chief.email.present? && chief_before != @job.chief_id
          JobMailer.create(@job, @job.chief, author: current_user, role: 'chief').deliver_later
        end
        @job.job_managers.each do |manager|
          if manager.email.present? && !managers_before.include?(manager.id)
            JobMailer.create(@job, manager, author: current_user, role: 'manager').deliver_later
          end
        end
        @job.job_technicians.each do |tech|
          if tech.email.present? && !technicians_before.include?(tech.id)
            JobMailer.create(@job, tech, author: current_user, role: 'technic').deliver_later
          end
        end
        if @job.closed? && closed_was == false
          redirect_to job_path( id: @job.id ), notice: I18n.t('notice', scope: 'jobs.closed', default: 'Job was successfully closed.')
        end
        format.html { redirect_to section_edit_job_path( id: @job.id, section: @section ), notice: I18n.t('notice', scope: 'jobs.update', default: 'Job was successfully updated.') }
        format.js do
          @chiefs = @users.chiefs
          @managers = @users.where.not(id: @job.chief_id)
          @technicians = @users.where.not(id: @job.chief_id)
          @job.contacts.build if @job.contacts.blank?
        end
        format.json { render :show, status: :ok, location: job_path(id: @job.id) }
      else
        format.html { redirect_to section_edit_job_path( id: @job.id, section: @section ), error: "#{@job.errors.messages.map{ |k,v| v }.join(', ')}" }
        format.js do
          @chiefs = @users.chiefs
          @managers = @users.where.not(id: @job.chief_id)
          @technicians = @users.where.not(id: @job.chief_id)
          @job.contacts.build if @job.contacts.blank?
        end
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job.author = current_user.label
    respond_to do |format|
      if @job.destroy
        format.js
        format.html do
          redirect_to root_path, notice: I18n.t('notice', scope: 'jobs.destroy', default: 'Job was successfully deleted.')
        end
      else
        format.html do
          redirect_to root_path, error: I18n.t('error', scope: 'jobs.destroy', default: 'Job was not deleted.')
        end
      end
    end
  end

  def print
    if params[:modal] == "1"
      @modal = params[:modal]
      @title = @job.title
      @icon = ("<i class='fa fa-eye'></i> #{ t('print', scope: '', default: 'Print') }").html_safe
      render layout: 'modal'
    end
    add_breadcrumb "<i class='fa fa-print'> #{I18n.t("breadcrumbs.jobs.print")}</i>".html_safe
  end

  def printed
    @sections = print_params
    respond_to do |format|
      format.html
      format.pdf do
        require 'combine_pdf'
        template = @job.template.blank? ? Settings.config.template : @job.template
        pdf_data = template.constantize.send(:new, @job, @sections.except('single', 'multiple') )
        pdf_data = pdf_data.render
        combined_file = CombinePDF.new
        combined_file << CombinePDF.parse(pdf_data)
        if @sections[:single] == 'true'
          @job.reports.singles.each do | report |
            combined_file << CombinePDF.load(report.file.path)
          end
        end
        if @sections[:multiple] == 'true'
          @job.reports.multiples.each do | report |
            combined_file << CombinePDF.load(report.file.path)
          end
        end
        send_data combined_file.to_pdf, filename: "report_#{@job.code}.pdf", type: 'application/pdf'
      end
    end
  end

  def logs
    @nobar = true
    @logs = Log.joins(:job).where('job_id = ?', @job.id)
    respond_to do |format|
      format.html do
        add_breadcrumb "<i class='fa fa-edit'> #{@job.title}</i>".html_safe, edit_job_path(id: @job.id), :title => I18n.t("breadcrumbs.samples.edit")
        add_breadcrumb "<i class='fa fa-history'> #{I18n.t("breadcrumbs.jobs.logs")}</i>".html_safe
      end
      format.json do
        dt_filter( @logs )
      end
    end
  end

  def reopen
    @url = params[:url] #job_params[:url]
    respond_to do |format|
      format.html do
        @modal = params[:modal]
        @title = @job.title
        @icon = ("<i class='fa fa-unlock'></i> #{ t('title', scope: 'jobs.reopen', default: 'Reopen job') }").html_safe
        render layout: 'modal'
      end
      format.js do
        @job.author = current_user.label
        @job.log_body = job_params[:reopen_reason]
        if @job.reopen
          redirect_to @url, notice: I18n.t('action', scope: 'jobs.reopen', default: 'Job was reopened.')
        end
      end
    end
  end

  def deleted
    @jobs = Job.deleted
  end

  def reports
    
  end

  def create_multiple_reports
    response = true
    errors = []
    analisy_ids = params[:analisy_ids]
    not_issueds = @job.analisies.where.not( id: @job.reports.issued.pluck(:analisy_id) ).left_outer_joins(:reports)
    unless analisy_ids.blank?
      analisy_ids.each do | analisy_id |
        analisy = not_issueds.find(analisy_id)
        response_mex = analisy.create_report
        unless response_mex.blank?
          response = false
          errors << response_mex
        end
      end
    end
    if response
      redirect_to job_reports_path( id: @job.id, section: 'notissued' ), notice: I18n.t('notice', scope: 'analisyreports.create', default: 'Analisy report was successfully created.')
    else
      redirect_to job_reports_path( id: @job.id, section: 'notissued' ), alert: "#{I18n.t('error', scope: 'analisyreports.create', default: 'Analisy report was not successfully created.')}<br/>#{ errors.join('<br/>') }"
    end
  end

  def destroy_multiple_reports
    response = true
    errors = []
    reports_ids = params[:analisy_ids]
    reason = params[:analisy_cancellation_reason] || "Cancellazione multipla"
    issueds = @job.reports.issued
    unless reports_ids.blank?
      reports_ids.each do | reports_id |
        report = issueds.find(reports_id)
        report.cancellation_reason = reason
        report.author = current_user.label
        unless report.destroy
          response = false
          errors << report.errors.full_messages.to_sentence unless report.errors.blank?
        end
      end
    end
    if response
      redirect_to job_reports_path( id: @job.id, section: 'issued' ), notice: I18n.t('notice', scope: 'analisyreports.destroy', default: 'Analisy report was successfully destroyed.')
    else
      redirect_to job_reports_path( id: @job.id, section: 'issued' ), alert: "#{I18n.t('error', scope: 'analisyreports.destroy', default: 'Analisy report was not successfully destroyed.')}<br/>#{ errors.join('<br/>') }"
    end
  end

  private
    def set_user
      @user = current_user
    end

    def set_job
      @job = Job.find(params[:id])
    end

    def set_jobs
      @searched = search_params

      @status = @searched.present? && @searched[:status].present? ? @searched[:status] : 'opened'
      @consolidated = @searched.present? && @searched[:consolidated].present? ? @searched[:consolidated] : ''
      @role = @searched.present? && @searched[:role].present? ? @searched[:role] : ''
      @manager_ids = @searched.present? && @searched[:manager_ids].present? ? @searched[:manager_ids] : ''
      @technician_ids = @searched.present? && @searched[:technician_ids].present? ? @searched[:technician_ids] : ''

      @jobs = Job.all

      if @status.present? && @status != 'all'
        @jobs = @jobs.send(@status)
      end
      if @consolidated.present?
        @jobs = @jobs.where(consolidated: @consolidated)
      end
      if @role == 'manager'
        @jobs = @jobs.managers_list(user_id: @user.id)
      elsif @role == 'technic'
        @jobs = @jobs.technicians_list(user_id: @user.id)
      end
      if @manager_ids.present?
        @jobs = @jobs.managers_list(user_id: @manager_ids)
      end
      if @technician_ids.present?
        @jobs = @jobs.technicians_list(user_id: @technician_ids)
      end

      @jobs = @jobs.distinct

    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.fetch(:job, {}).permit(:id, :code, :title, :revision, :body, :open_at, :close_at, :planned_closure_at, :job_type, :pa_support, :n_samples, :create_samples, :create_analisies, :metadata, :customer, :address, :requirements, :status, :author, :consolidated, :chief_id, :institutions, :other_resources, :reopen_reason, :unlock_validation_reason, :timetables_validated, :url, job_manager_ids: [], job_technician_ids: [], analisies_list: [], contacts_attributes: [ :id, :label, :tel1, :tel2, :cell, :fax, :email, :priority, :_destroy ], attachments_attributes: [ :category, :file ] )
    end

    def search_params
      params.fetch(:job, {}).permit(:id, :status, :consolidated, :role, :format, :authenticity_token, :_, :locale, :modal, :section, :_method, :job, :format, :string, :code, :body, :customer, :address, :contact, :tel1, :tel2, :fax, :cell, :email, :institutions, :requirements, :other_resources, :managers, :technics, job_manager_ids: [], job_technician_ids: []) if params[:job].present?
    end

    def print_params
      params.fetch(:job, {}).permit( :id, :details, :design, :timetables, :samples, :analisies, :single, :multiple, :logs )
    end
end
