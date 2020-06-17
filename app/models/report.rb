class Report < ApplicationRecord
  belongs_to :job, :class_name => "Job", :foreign_key => "job_id", required: true, :validate => true
  belongs_to :analisy, :class_name => "Analisy", :foreign_key => "analisy_id", optional: true
  has_one :sample, :through => :analisy, source: :sample

  enum report_type: Settings.report_types

  attr_accessor :author, :terms_of_service, :general_body

  has_many :report_results, :class_name => "AnalisyResultReport", source: :report
  has_many :results, :class_name => "AnalisyResult", through: :report_results, source: :analisy_result
  has_many :analisies, :through => :results, source: :analisy
  has_many :samples, :through => :analisies, source: :sample
  has_many :types, :through => :analisies, source: :type

  accepts_nested_attributes_for :results, :reject_if => :all_blank, :allow_destroy => true

  has_many :logs, as: :loggable
  accepts_nested_attributes_for :logs, :reject_if => :all_blank, :allow_destroy => true

  has_attached_file :file, :url => '/files/:parent_code/reports/:filename', :path => ':rails_root/private:url'

  validates_attachment_content_type :file, :content_type => ['application/pdf'], :if => :pdf_attached?
  validates_attachment_size :file, :less_than => 2.megabytes
  validates_attachment_presence :file
  do_not_validate_attachment_file_type :file

  validates_associated :job
  validates_associated :analisy, if: :single?
  validates_presence_of :result_ids
  validates_uniqueness_of :analisy_id, conditions: -> { issued.singles }
  validates_uniqueness_of :code

  validates_presence_of :cancellation_reason, on: :destroy

  # validates_acceptance_of :terms_of_service, :accept => 'yes'

  before_validation :prerequisite
  before_save :create_log
  # before_create :generate_report
  after_destroy_commit :destroy_report

  default_scope { order(created_at: :desc) }
  scope :issued, -> { where("reports.cancelled_at is null") }
  scope :cancelled, -> { where(" not reports.cancelled_at is null") }
  scope :created_in, ->(year) { where( "extract(YEAR from created_at ) = ?", year ) }

  scope :singles, -> { where.not("reports.analisy_id is null") }
  scope :multiples, -> { where("reports.analisy_id is null") }

  def self.report_type_collection
    report_types.map{|v,k| [I18n.t(v, scope: "reports.report_types", default: v), v]}
  end

  def issued_on
    I18n.l created_at.to_date if created_at.present?
  end

  def cancelled_on
    I18n.l cancelled_at.to_date if cancelled_at.present?
  end

  def delete
    destroy
  end

  def destroy
    # Funzione di scrittura sul file PDF annullato!!!
    require 'combine_pdf'
    filename = "#{file.path}"
    filename_watermark = "private/files/reports/watermark.pdf"

    if File.exist?(filename)
      begin
        pdf = CombinePDF.load( filename )
      rescue Exception => exception
        Rails.logger.error "[CombinePDF] Exception #{exception.class}: #{exception.message}"
      end
      if pdf
        self.cancelled_at = I18n.l Date.today
        # Pagina di annullamento
        sections = { destroyer: "true"}
        template = Settings.config.template
        destroyer = template.constantize.send(:new, self, sections)
        body = CombinePDF.parse( destroyer.render )
        pdf << body
        # watermark
        FileUtils.rm_f( filename_watermark ) if File.exist? filename_watermark
        if !File.exists? filename_watermark
          Prawn::Document.generate( filename_watermark ) do
            text_box "ANNULLATO il #{ I18n.l Date.today }", :size => 60, character_spacing: 10, :width => bounds.width, :height => bounds.height, :align => :center, :valign => :center, :at => [0, bounds.height], :rotate => 45, :rotate_around => :center
          end
        end
        watermark = CombinePDF.load(filename_watermark).pages[0]
        pdf.pages.each {|page| page << watermark}
        pdf.save filename
      end
    end
    if save
      FileUtils.rm_f( filename_watermark )
      return true
    else
      return false
    end
  end

  def pdf_attached?
    self.file.file?
  end

  def preview_pdf
    Rails.logger.debug 'in preview_pdf'
    Rails.logger.debug "self.author -> #{self.author}"
    Rails.logger.debug "self.code -> #{self.code}"
    self.code = Time.now.strftime("%y%m%d%H%M%S") if code.blank?
    if report_type == 'single'
      generate_report_single '-preview'
    elsif report_type == 'multiple'
      generate_report_multiple '-preview'
    end
    Rails.logger.debug 'esco da preview_pdf'
  end

  private

    def prerequisite
      self.author = 'System' if author.blank?
      self.code = Time.now.strftime("%y%m%d%H%M%S") if code.blank?
      if new_record?
        if report_type == 'single'
          generate_report_single
        elsif report_type == 'multiple'
          generate_report_multiple
        end
      end
    end

    def generate_report_single(fname = '')
      Rails.logger.debug 'in generate_report_single'
      Rails.logger.debug "code ->#{code}<-"
      filename = "#{ code }#{ fname }.pdf"
      path = "private/files/reports/"
      FileUtils.mkdir_p(path) unless File.exists?(path)
      full_file = "#{path}#{filename}"
      sections = { single: "true"}
      template = Settings.config.template
      pdf = template.constantize.send(:new, self, sections)
      pdf.render_file(full_file)
      if File.exists?( full_file )
        Rails.logger.debug "full_file ->#{full_file}<-"
        self.file = File.open( full_file )
        # È necessario salvare il file per avero nella corretta cartella per il download!
        self.file.save
        Rails.logger.debug "self.file.path ->#{self.file.path}<-"
      else
        return "#{report.code}: #{report.errors.full_messages.to_sentence}"
      end
    end

    def generate_report_multiple(fname = '')
      Rails.logger.debug 'in generate_report_multiple'
      Rails.logger.debug "code ->#{code}<-"
      filename = "#{ code }#{ fname }.pdf"
      path = "private/files/reports/"
      FileUtils.mkdir_p(path) unless File.exists?(path)
      full_file = "#{path}#{filename}"
      sections = { multiple: "true"}
      template = Settings.config.template
      pdf = template.constantize.send(:new, self, sections)
      pdf.render_file(full_file)
      if File.exists?( full_file )
        Rails.logger.debug "full_file ->#{full_file}<-"
        self.file = File.open( full_file )
        # È necessario salvare il file per avero nella corretta cartella per il download!
        self.file.save
        Rails.logger.debug "self.file.path ->#{self.file.path}<-"
      else
        return "#{report.code}: #{report.errors.full_messages.to_sentence}"
      end
    end

    def destroy_report
      path = "private/files/reports/"
      File.delete("#{file.url}") if File.exists?( "#{file.url}" )
      File.delete("#{path}#{ code }") if File.exists?( "#{path}#{ code }" )
    end

    Paperclip.interpolates :parent_code  do |attachment, style|
      "#{attachment.instance.job.code}"
    end
end
