class Analisy < ApplicationRecord
  belongs_to :sample, :class_name => "Sample", :foreign_key => "sample_id"
  belongs_to :type, :class_name => "AnalisyType", :foreign_key => "analisy_type_id"
  has_one    :job, :through => :sample, source: :job
  has_one    :report, -> { issued }, :class_name => 'Report', dependent: :destroy
  has_many   :results, :class_name => "AnalisyResult", :foreign_key => "analisy_id"
  has_many   :nuclides, :through => :results, source: :nuclide

  has_many :reports, through: :results, source: :reports

  has_many :roles, -> { order role: :asc }, :class_name => "AnalisyUser", :foreign_key => "analisy_id"
  has_many :analisy_technics, -> { where role: 'technic' }, :class_name => "AnalisyUser", :foreign_key => "analisy_id", before_add: [Proc.new {|p,d| d.role = 2} ]
  has_many :analisy_headtests, -> { where role: 'headtest' }, :class_name => "AnalisyUser", :foreign_key => "analisy_id", before_add: [Proc.new {|p,d| d.role = 1} ]
  has_many :analisy_chiefs, -> { where role: 'chief' }, :class_name => "AnalisyUser", :foreign_key => "analisy_id", before_add: [Proc.new {|p,d| d.role = 0} ]
  has_many :analisy_chief_users, :through => :analisy_chiefs, source: :user
  has_many :analisy_headtest_users, :through => :analisy_headtests, source: :user
  has_many :analisy_technic_users, :through => :analisy_technics, source: :user

  accepts_nested_attributes_for :sample, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :analisy_chief_users, reject_if: lambda { |user| user[:_destroy].blank? && user[:id].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :analisy_headtest_users, reject_if: lambda { |user| user[:_destroy].blank? && user[:id].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :analisy_technic_users, reject_if: lambda { |user| user[:_destroy].blank? && user[:id].blank? }, :allow_destroy => true

  accepts_nested_attributes_for :results, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :reports, reject_if: :all_blank, allow_destroy: true

  has_many :logs, as: :loggable
  accepts_nested_attributes_for :logs, :reject_if => :all_blank, :allow_destroy => true

  attr_accessor :author, :skip_validate, :sample_attributes

  before_validation :prerequisite

  validates :analisy_type_id, presence: true, uniqueness: { :scope => :sample_id }
  validates :reference_at, presence: true, date: true

  validates :analisy_chief_user_ids, presence: true, :unless => Proc.new { |analisy| analisy.skip_validate == 'true' }
  validates :analisy_headtest_user_ids, presence: true, :unless => Proc.new { |analisy| analisy.skip_validate == 'true' }
  validates :analisy_technic_user_ids, presence: true, :unless => Proc.new { |analisy| analisy.skip_validate == 'true' }

  before_save :create_log

  default_scope { order(sample_id: :asc, code: :asc) }


  scope :created_in, ->(year) { where( "extract(YEAR from created_at ) = ?", year ) }

  def reference_on
    I18n.l reference_at.to_date if reference_at.present?
  end

  def created_on
    I18n.l created_at.to_date if created_at.present?
  end

  def fullcode
    return "#{ created_at.strftime('%Y') }-#{ code }"
  end

  private

  def prerequisite
    self.author = 'System' if author.blank? || author.nil?
    self.reference_at = Time.now if reference_at.blank?
    analisy_headtests_exists?
    analisy_technics_exists?
  end

  def analisy_headtests_exists?
    if analisy_headtest_user_ids.present?
      analisy_headtest_user_ids.each do | user_id |
        self.analisy_headtest_user_ids.delete(user_id) unless User.headtests.pluck(:id).include?( user_id )
      end
    end
    return analisy_headtest_user_ids.present?
  end
  def analisy_technics_exists?
    if analisy_technic_user_ids.present?
      analisy_technic_user_ids.each do | user_id |
        self.analisy_technic_user_ids.delete(user_id) unless User.technics.pluck(:id).include?( user_id )
      end
    end
    return analisy_technic_user_ids.present?
  end
end
