class BaseController < ApplicationController

  def need_login
    unless user_signed_in?
      flash[:alert] = '请先登录'
      redirect_to welcome_vis_static_pages_path
    end
  end

  def need_admin
    role = Role.find_or_create_by name: 'admin', is_valid: 1
    unless current_user.access? [role.id]
      flash[:alert] = '非管理员不可访问。'
      redirect_to welcome_vis_static_pages_index_path
    end
  end

  def need_warehouseman
    role = Role.find_or_create_by name: 'warehouseman', is_valid: 1
    unless current_user.access? [role.id]
      flash[:alert] = '此操作只有仓库管理员可做。'
      redirect_to '/vis/static_pages/welcome/'
    end
  end

  def need_super_admin
    role = Role.find_or_created_by name: 'super_admin', is_valid: 1
    unless current_user.access? [role.id]
      flash[:alert] = '此操作只有超级管理员可做。'
      redirect_to '/vis/static_pages/welcome/'
    end
  end
end