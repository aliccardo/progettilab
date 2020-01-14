class User < ApplicationRecord
  require 'open-uri'
  devise :ldap_authenticatable, :trackable, :timeoutable, :lockable
  attr_accessor :login, :password

  has_one_attached :signature
  attr_accessor :author, :metadata

  before_validation :prerequisite
  before_save :create_log

  validates :username, presence: true, uniqueness: true
  validates :label, presence: true, uniqueness: true

  has_many :logs, as: :loggable
  accepts_nested_attributes_for :logs, :reject_if => :all_blank, :allow_destroy => true

  has_many :roles, :class_name => 'JobRole', inverse_of: :user
  has_many :jobs, :through => :roles, source: :job
  has_many :roles_managers, -> { where manager: true }, :class_name => 'JobRole', before_add: [Proc.new {|p,d| d.manager = true} ]
  has_many :roles_technicians, -> { where manager: false }, :class_name => 'JobRole', before_add: [Proc.new {|p,d| d.manager = false} ]

  has_many :jobs_as_manager, :through => :roles_managers, source: :job
  has_many :jobs_as_technician, :through => :roles_technicians, source: :job

  has_many :user_analisies_as_headtest, -> { where role: 'headtest' }, :class_name => 'AnalisyUser', :foreign_key => "user_id"
  has_many :analisies_as_headtest, :through => :user_analisies_as_headtest, source: :analisy
  has_many :reports_waiting, :through => :analisies_as_headtest, source: :reports

  has_many :logs, as: :loggable
  accepts_nested_attributes_for :logs, :reject_if => :all_blank, :allow_destroy => true

  default_scope { order(label: :asc) }
  scope :enabled, -> { where(locked_at: nil) }
  scope :deleted, -> { where.not(locked_at: nil) }

  scope :technics, -> { where(technic: true) }
  scope :headtests, -> { where(headtest: true) }
  scope :chiefs, -> { where(chief: true) }

  def delete
    destroy
  end

  def destroy
    update(locked_at: Time.now)
  end

  def manager?(job_id: '')
    roles = roles_managers
    roles = roles.where(job_id: job_id) if job_id.present?
    roles.present?
  end

  private

  def prerequisite
    self.author = 'System' if author.blank? || author.nil?
    get_data if new_record?
    # lock_on_create if new_record?
  end

  def lock_on_create
    self.locked_at = Time.now
  end

  def self.get_users
    users = []
    begin
      data = JSON.parse(
        open("#{Rails.application.credentials.api[:link]}?#{Rails.application.credentials.api[:filter]}",
        http_basic_authentication: [Rails.application.credentials.api[:login], Rails.application.credentials.api[:secret_access_key]],
        ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
      )
      local_users = User.enabled.pluck(:username)
      users = data.map{ |u| { login: u['login'], nominativo: u['nominativo'] } if u['login'].present? && !local_users.include?( u['login'] ) }.reject{|u| u.blank? } unless data.blank? || data == "\"\""
    rescue => ex
    end
    return users
  end

  def get_data
    unless Rails.env.test?
      begin
        data = JSON.parse(
          open("#{Rails.application.credentials.api[:link]}?login=#{username}",
          http_basic_authentication: [Rails.application.credentials.api[:login], Rails.application.credentials.api[:secret_access_key]],
          ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
        )

        unless data.blank? || data == "\"\""
          self.label = data['nominativo'].blank? ? username : data['nominativo']
          self.email = data['email']
          self.sex = data['sesso']
          self.locked_at = Time.now if !data['stato'].blank? && data['stato'] == 'scaduto'
        end
      rescue => ex
        self.label = username.gsub('.', ' ').titleize if label.blank?
      end
    else
      self.label = username.gsub('.', ' ').titleize if label.blank?
    end
  end
end
