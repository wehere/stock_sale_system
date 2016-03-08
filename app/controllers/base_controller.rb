class BaseController < ApplicationController

  def need_login
    unless user_signed_in?
      flash[:alert] = '请先登录'
      redirect_to welcome_vis_static_pages_path
    end
  end

  def need_admin
    unless current_user.admin?
      flash[:alert] = '非管理员不可访问。'
      redirect_to welcome_vis_static_pages_index_path
    end
  end

  def need_warehouseman
    unless current_user.warehouseman?
      flash[:alert] = '此操作只有仓库管理员可做。'
      redirect_to '/vis/static_pages/welcome/'
    end
  end

  def need_super_admin
    unless current_user.super_admin?
      flash[:alert] = '此操作只有超级管理员可做。'
      redirect_to '/vis/static_pages/welcome/'
    end
  end
end