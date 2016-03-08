class Sp::UsersController < BaseController
  before_filter :need_super_admin
  layout 'super_admin'
  def index
    @users =User.all
  end
end