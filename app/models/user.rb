class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :company
  has_many :comments
  has_many :users
  delegate :simple_name, to: :company, prefix: true, allow_nil: true
  belongs_to :store
  has_and_belongs_to_many :roles

  def access? require
    return true if require.blank?
    !(self.roles.pluck(:id)&require).blank?
  end

end
