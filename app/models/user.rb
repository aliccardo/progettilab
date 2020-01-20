class User < ApplicationRecord
  # require 'open-uri'
  devise :ldap_authenticatable, :trackable, :timeoutable, :lockable

  attr_accessor :password

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
      local_users = User.enabled.pluck(:username)
      base = Rails.application.credentials.ldap[:base]
      filter = Net::LDAP::Filter.ne("lockoutTime", "false")
      attrs = Rails.application.credentials.ldap[:attributes]
      login = "#{Rails.application.credentials.ldap[:admin]}#{Rails.application.credentials.ldap[:domain]}"
      pwd = "#{Rails.application.credentials.ldap[:password]}"
      host = Rails.application.credentials.ldap[:host]
      port = Rails.application.credentials.ldap[:port]
      ldap = Net::LDAP.new host: host, port: port, auth: { method: :simple, username: login, password: pwd }
      data = []
      filter = Net::LDAP::Filter.eq('cn', '*')
      ldap.search(base: base, filter: filter, attributes: attrs, return_result: false) do |entry|
        e = {}
        entry.each do |attribute, values|
          e.store attribute.to_sym, values.first.strip
        end
        data << e
      end
      Rails.logger.debug("Result: #{ldap.get_operation_result.inspect}")
      users = data.map{ |u| { login: u[:samaccountname], label: u[:cn], nominativo: u[:cn], username: u[:cn], email: u[:mail] } if u[:samaccountname].present? && !local_users.include?( u[:samaccountname] ) }.reject{|u| u.blank? } unless data.empty?
    rescue => ex
      Rails.logger.debug("Rescued: #{ex}")
      raise ex unless Rails.env.production?
    end
    return users
  end

  def get_data
    unless Rails.env.test?
      Rails.logger.debug "get_data"
      base = Rails.application.credentials.ldap[:base]
      attrs = Rails.application.credentials.ldap[:attributes]
      login = "#{Rails.application.credentials.ldap[:admin]}#{Rails.application.credentials.ldap[:domain]}"
      pwd = "#{Rails.application.credentials.ldap[:password]}"
      host = Rails.application.credentials.ldap[:host]
      port = Rails.application.credentials.ldap[:port]
      begin
        ldap = Net::LDAP.new host: host, port: port, auth: { method: :simple, username: login, password: pwd }
        filter = Net::LDAP::Filter.eq('samaccountname', self.username)
        ldap.search(base: base, filter: filter, attributes: attrs, return_result: false) do |entry|
          ldap_param = entry[:cn]
          self.label = ldap_param.first.to_s.strip unless ldap_param.nil?
          Rails.logger.debug "#{self.username} ha label: #{self.label}."
          ldap_param = entry[:mail]
          self.email =  ldap_param.first.to_s.strip unless ldap_param.nil?
          Rails.logger.debug "#{self.username} ha mail: #{self.email}."
          # non c'è questo attributo su LDAP
          # ldap_param = entry[:lockoutTime]
          # locked = ldap_param.first unless ldap_param.nil?
          # Rails.logger.debug "#{self.username} è #{locked ? 'bloccato dal' + locked.to_s : 'attivo'}."
          # self.locked_at = Time.now if locked
          # non c'è questo attributo su LDAP
          # self.sex = Devise::LDAP::Adapter.get_ldap_param(self.username,"???").first
        end
      rescue => ex
        Rails.logger.debug("Rescued: #{ex}")
        raise ex unless Rails.env.production?
        self.label = username.gsub('.', ' ').titleize if label.blank?
      end
    else
       Rails.logger.debug "get_data(), Rails.env.test? #{Rails.env.test?}"
      self.label = username.gsub('.', ' ').titleize if label.blank?
    end
  end
end
