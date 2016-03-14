class Role < ActiveRecord::Base
  has_and_belongs_to_many :users

  def self.none_super_admin_roles
    Role.where("name <> ?", 'super_admin')
  end
end