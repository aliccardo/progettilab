class AnalisyResult < ApplicationRecord
  belongs_to :analisy, :class_name => "Analisy", :foreign_key => "analisy_id" #, required: true
  belongs_to :nuclide, :class_name => "Nuclide", :foreign_key => "nuclide_id", required: true

  belongs_to :result_unit, :class_name => "Unit", :foreign_key => "result_unit_id"
  belongs_to :indecision_unit, :class_name => "Unit", :foreign_key => "indecision_unit_id"
  belongs_to :mcr_unit, :class_name => "Unit", :foreign_key => "mcr_unit_id"

  has_many :analisy_result_reports, :class_name => "AnalisyResultReport", source: :analisy_result
  has_many :reports, through: :analisy_result_reports, :class_name => "Report", source: :report
  accepts_nested_attributes_for :reports, :reject_if => :all_blank, :allow_destroy => true

  has_one :sample, :through => :analisy
  has_one :job, :through => :sample
  has_one :analisy_type, :through => :analisy, source: :type

  has_many :logs, as: :loggable
  accepts_nested_attributes_for :logs, :reject_if => :all_blank, :allow_destroy => true

  accepts_nested_attributes_for :analisy, :reject_if => :all_blank, :allow_destroy => true

  attr_accessor :author, :device, :import

  validates :full_result, presence: true, if: Proc.new { |result| result.absence_analysis.blank? || result.mcr.blank?}
  validates :full_result_with_nuclide, presence: true, if: Proc.new { |result| result.absence_analysis.blank? || result.mcr.blank?}

  validates_presence_of :result_unit_id, message: "Unità di misura mancante!", on: :update, if: Proc.new { |result| result.absence_analysis.blank?}
  validates_presence_of :indecision_unit_id, message: "Unità di misura della incertezza mancante!", on: :update, if: Proc.new { |result| result.absence_analysis.blank?}
  validates_presence_of :mcr_unit_id, message: "Unità di misura della MCR mancante!", on: :update, if: Proc.new { |result| result.absence_analysis.blank?}

  before_validation :prerequisite
  before_save :create_log

  scope :issued, -> { includes(:reports).issued }
  scope :notissued, -> { AnalisyResultReport.where(report_id: @job.reports.issued.ids).where.not(analisy_result_id: @job.results.ids) }

  def symbols
    [ '±', '<' ]
  end

  def nuclides
    AnalisyType.find(analisy.analisy_type_id).nuclides
  end

  def destroy
    unless reports.present?
      false
    else
      super
    end
  end

  def self.has_report?
    reports.present?
  end

  def set_results
    mcr_text = (mcr.blank?)? '':  "; MCR=#{mcr} #{mcr_unit.html unless mcr_unit_id.blank?}"
    Rails.logger.debug "mcr ->#{mcr_text}"
    Rails.logger.debug "result ->#{result}"
    Rails.logger.debug "indecision ->#{indecision}"
    Rails.logger.debug "result_before_type_cast ->#{result_before_type_cast}"
    Rails.logger.debug "indecision_before_type_cast ->#{indecision_before_type_cast}"
    self.result_precision = set_precision result_before_type_cast
    self.indecision_precision = set_precision indecision_before_type_cast
    Rails.logger.debug "self.result_precision ->#{self.result_precision}"
    Rails.logger.debug "self.indecision_precision->#{self.indecision_precision}"
    self.full_result = unless result.blank?
      Rails.logger.debug "symbol è: #{symbol}."
      case symbol
        when "±"
          "#{result_full_decimal} #{result_unit.html unless result_unit_id.blank?} #{symbol} #{indecision_full_decimal} #{indecision_unit.html unless result_unit_id.blank?}#{mcr_text unless mcr_text.blank? }"
        when "<"
          "#{symbol} #{result_full_decimal} #{result_unit.html unless result_unit_id.blank?}#{mcr_text unless mcr_text.blank? }"
        else
          (mcr_text.blank?)? 'n.d.': mcr_text[2..mcr_text.size]
      end
    else
      Rails.logger.debug "ritorno : #{mcr_text[2..mcr_text.size]}."
      mcr_text[2..mcr_text.size]
    end
  end

  def to_html( value = full_result_with_nuclide )
    if value.present?
      if value.downcase.include?('m2')
        value = value.gsub('m2', 'm<sup>2</sup>')
      end
      if value.downcase.include?('m3')
        value = value.gsub('m3', 'm<sup>3</sup>')
      end
      if value.downcase.include?('m-1')
        value = value.gsub('m-1', 'm<sup>-1</sup>')
      end
      if value.downcase.include?('m-2')
        value = value.gsub('m-2', 'm<sup>-2</sup>')
      end
      if value.downcase.include?('m-3')
        value = value.gsub('m-3', 'm<sup>-3</sup>')
      end
    end
    return value
  end

  def to_report( value = full_result_with_nuclide )
    value.gsub!('<sup>', '&sup')
    value.gsub!('</sup>', ';')
    return value
  end

  def for_report
    text = ''
    text += "#{nuclide.title}: " unless nuclide.blank?
    text += full_result.blank? ? 'n.d.' : "#{full_result}"
    self.full_result_with_nuclide = text
  end

  def result_full_decimal
    value_full_decimal result, result_precision unless result.nil?
  end

  def indecision_full_decimal
    value_full_decimal indecision, indecision_precision  unless result.nil?
  end

  private

  def prerequisite
    if new_record? && import.blank?
      self.full_result = 'n.d.'
    else
      Rails.logger.debug "absence_analysis è presente? #{absence_analysis.present?}."
      if absence_analysis.present?
        self.result = ''
        self.result_precision = nil
        self.result_unit_id = :null
        self.indecision = ''
        self.indecision_precision = nil
        self.indecision_unit_id = :null
        self.mcr = ''
        self.mcr_unit_id = :null
        self.full_result = ''
        self.absent = true
        self.full_result = absence_analysis
      else
        errors.add :result_full_decimal, 'campo obbligatorio, se MCR è vuoto' if result.blank? && mcr.blank?
        errors.add :result_unit_id, 'campo obbligatorio, se MCR è vuoto' if result_unit_id.blank? && mcr.blank?
        errors.add :indecision_full_decimal, 'campo obbligatorio, se MCR è vuoto' if symbol == '±' && indecision.blank? && mcr.blank?
        errors.add :indecision_unit_id, 'campo obbligatorio, se MCR è vuoto' if symbol == '±' && indecision_unit_id.blank? && mcr.blank?
        errors.add :mcr_unit_id, 'campo obbligatorio, se MCR ha un valore' if mcr_unit_id.blank? && mcr.present?
        if errors.blank?
          self.absent = false
        end
        Rails.logger.debug "imposto i risultati chiamando set_results."
        set_results
        Rails.logger.debug "self.full_result è: #{self.full_result}."
      end
    end
    for_report
    self.author = analisy.try(:author) || 'System'
  end

  def set_precision(text)
    return 0 if text.nil?
    (text.include?('.') && ! text.end_with?('.'))? text.split('.').last.length : 0
  end

  def value_full_decimal(x, x_precision)
    x_parts  = x.to_s.split '.'
    x_precision ||= x_parts.last.length
    "#{x_parts.first}.#{(x_parts.last + ('0' * x_precision))[0...x_precision]}"
  end
end
