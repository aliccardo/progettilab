class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format =~ %r{application/json} }
  before_action :set_locale
  before_action :redirect_to_sign_in, unless: :user_signed_in?
  before_action :authenticate_user!

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.json { head :notfound, content_type: 'text/html' }
      format.js { head :notfound, content_type: 'text/html' }
      format.html{ set_locale; redirect_to( jobs_url, :alert => t("site_not_found", default: "Site Not Found") ) }
    end
  end
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.js   { head :forbidden, content_type: 'text/html' }
      format.html{ render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false }
    end
  end

  def set_locale
    I18n.locale = params[:locale] || extract_locale_from_accept_language_header || I18n.default_locale
  end

  def set_role
    @role = @job.role?(@user)
  end

  def dt_filter( recordset )
    unless recordset.blank?
      @full_count = recordset.count
      @draw = params[:draw] || 1
      searched = params[:search] || ''
      start = params[:start] || 0
      length = params[:length] || @full_count
      length = @full_count if length.to_i < 0
      columns = params[:columns] || []
      order = params[:order] || []
      
      where = []
      order_by = []
      unless columns.blank?
        unless order.blank?
          order.values.each do | row |
            icolumn = row.values[0]
            order  = row.values[1]
            column = columns[icolumn].values[1]
            orderable = columns[icolumn].values[3]
            if orderable && column.present?
              order_by << "#{ column } #{ order }"
            end
          end
        end
      
        unless searched.blank? || searched.values[0].blank?
          columns.values.each do | col |
            if col.values[2] == "true" && col.values[1].present?
              if ( searched.values[0].try(:to_i).is_a?(Numeric) )
                where << "#{col.values[1]}::TEXT ilike '%#{searched.values[0]}%'"
              else
                where << "#{col.values[1]} ilike '%#{searched.values[0]}%'"
              end
            end
          end
        end
        
        where = where.blank? ? '' : where.join( ' OR ' )
        order_by = order_by.blank? ? nil : order_by.join( ', ' )
        filtered = recordset.where( where )
        @filtered_count = filtered.count
        @paginated = filtered.reorder( order_by ).offset( start ).limit( length )

      else
        @filtered_count = recordset.count
        @paginated = recordset
      end
    else
      @draw = 1
      @full_count = 0
      @paginated = recordset
      @filtered_count = 0
    end
  end


  private

  def redirect_to_sign_in
    redirect_to new_user_session_path
  end

  def default_url_options(options = {})
    if I18n.default_locale != I18n.locale
      {locale: I18n.locale}.merge options
    elsif I18n.default_locale != params[:locale]
      {locale: params[:locale]}.merge options
    else
      {locale: nil}.merge options
    end
  end

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

  def record_not_found
    redirect_to root_path, error: I18n.t('record_not_found', scope: 'errors', default: 'Record not found')
  end

end

