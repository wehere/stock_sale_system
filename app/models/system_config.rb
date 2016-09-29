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
