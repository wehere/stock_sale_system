# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  is_valid   :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users

  def self.none_super_admin_roles
    Role.where("name <> ?", 'super_admin')
  end
end
