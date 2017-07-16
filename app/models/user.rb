# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  company_id             :integer
#  user_name              :string(255)
#  terminal_password      :string(255)
#  serial_number          :string(255)
#  store_id               :integer
#

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

  def employee?
    !self.company.blank?
  end


  def admin?
    role = Role.find_or_create_by name: 'admin', is_valid: 1
    access? [role.id]
  end

  # 设置此用户为管理员
  def set_admin
    roles << Role.where(name: 'admin').first
  end

  def super_admin?
    role = Role.find_or_create_by name: 'super_admin', is_valid: 1
    access? [role.id]
  end

  def warehouseman?
    role = Role.find_or_create_by name: 'warehouseman', is_valid: 1
    access? [role.id]
  end

  def set_role role_ids
    if super_admin?
      self.roles = Role.where("id in (?) or name = ?", role_ids, 'super_admin')
      self.save!
    elsif admin?
      self.roles = Role.where("(id in (?) or name = ?) and name <> ?", role_ids, 'admin', 'super_admin')
      self.save!
    else

    end
  end

  def self.link_company options
    user = User.find_by_id(options[:user_id])
    BusinessException.raise '请给出用户ID' if user.blank?
    company = Company.find_by_id(options[:company_id])
    BusinessException.raise '请给出公司ID' if company.blank?
    user.company = company
    user.save!
  end

  def update_terminal_info options
    self.user_name = options[:user_name] unless options[:user_name].blank?
    self.terminal_password = options[:terminal_password] unless options[:terminal_password].blank?
    self.save!
  end

end
