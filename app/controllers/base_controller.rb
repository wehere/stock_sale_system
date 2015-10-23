class BaseController < ApplicationController

  def need_login
    unless user_signed_in?
      flash[:alert] = '请先登录'
      redirect_to welcome_vis_static_pages_path
    end
  end
end