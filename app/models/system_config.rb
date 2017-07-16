# == Schema Information
#
# Table name: system_configs
#
#  id         :integer          not null, primary key
#  k          :string(255)
#  v          :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SystemConfig < ActiveRecord::Base
  validates :k, :presence => true

  def self.get_value k
    config = SystemConfig.find_or_create_by! k: k
    config.v
  end

  def self.v k, default=''
    sc = SystemConfig.where(k: k).first
    if sc.blank?
      sc = SystemConfig.find_or_create_by!(k: k, v: default)
    end
    return sc.v
  end
end
