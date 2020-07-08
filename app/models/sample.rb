class Sample < ApplicationRecord
  belongs_to :job, :class_name => "Job", :foreign_key => "job_id"
  belongs_to :type_matrix, :class_name => "MatrixType", :foreign_key => "type_matrix_id"

  has_many :analisies, :class_name => "Analisy", dependent: :destroy
  accepts_nested_attributes_for :analisies, :reject_if => :all_blank, :allow_destroy => true

  has_many :reports, :through => :analisies, source: :report

  has_many :analisy_types, :through => :analisies, source: :type
  accepts_nested_attributes_for :analisy_types, :reject_if => :all_blank, :allow_destroy => true

  has_many :results, :through => :analisies
  accepts_nested_attributes_for :results, :reject_if => :all_blank, :allow_destroy => true

  has_many :attachments, as: :attachable, dependent: :destroy
  accepts_nested_attributes_for :attachments, :reject_if => :all_blank, :allow_destroy => true

  has_many :logs, as: :loggable
  accepts_nested_attributes_for :logs, :reject_if => :all_blank, :allow_destroy => true

  attr_accessor :skip_presence, :author, :category_id

  before_validation :prerequisite
  before_save :create_log

  validates :created_by, presence: true
  validates :updated_by, presence: true
  validates :start_at, presence: true, date: { before_or_equal_to: :stop_at, message: I18n.t('greater', scope: 'samples.errors.start_at', default: 'not be least than stop date') }
  validates :stop_at, presence: true, date: { after_or_equal_to: :start_at, message: I18n.t('least-start', scope: 'samples.errors.accepted_at', default: 'not be least than start date') }
  validates :start_at, :stop_at, date: { before_or_equal_to: :accepted_at, message: I18n.t('greater', scope: 'samples.errors.accepted_at', default: 'not be least than accepted date') }
  validates :category_id, presence: true
  validates :type_matrix_id, presence: true
  validates_uniqueness_of :device, :scope => :job, :unless => Proc.new { |sample| sample.device.blank? }
  validates :latitude, numericality: { allow_blank: true, only_float: true }
  validates :longitude, numericality: { allow_blank: true, only_float: true }

  default_scope { order(job_id: :asc, code: :asc) }
  scope :created_in, ->(year) { where( "extract(YEAR from created_at ) = ?", year ) }

  after_initialize do
    self.category_id = type_matrix.pid if type_matrix.present? && type_matrix.pid.present?
  end

  def start_on
    I18n.l start_at.to_date if start_at.present?
  end

  def stop_on
    I18n.l stop_at.to_date if stop_at.present?
  end

  def accepted_on
    I18n.l accepted_at.to_date if accepted_at.present?
  end

  private

  def prerequisite
    self.author = updated_by || 'System'
    self.accepted_at ||= Date.today
    #self.latitude, self.longitude = to_latitudelongitude if ( latitude_dms.present? || longitude_dms.present? )
    self.category_id = type_matrix.pid if type_matrix.present? && type_matrix.pid.present?
  end
end
