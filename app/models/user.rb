class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :company
  has_many :comments
  has_many :users
  # delegate :simple_name, to: :company, prefix: true, allow_nil: true
  belongs_to :store
  has_and_belongs_to_many :roles

  def access? require
    return true if require.blank?
    !(self.roles.pluck(:id)&require).blank?
  end

  def admin?
    role = Role.find_or_create_by name: 'admin', is_valid: 1
    access? [role.id]
  end

  def super_admin?
    role = Role.find_or_create_by name: 'super_admin', is_valid: 1
    access? [role.id]
  end

  def warehouseman?
    role = Role.find_or_create_by name: 'warehouseman', is_valid: 1
    access? [role.id]
  end

  def self.link_company options
    user = User.find_by_id(options[:user_id])
    BusinessException.raise '请给出用户ID' if user.blank?
    company = Company.find_by_id(options[:company_id])
    BusinessException.raise '请给出公司ID' if company.blank?
    user.company = company
    user.save!
  end

end
