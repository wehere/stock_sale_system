class Vis::StaticPagesController < ApplicationController
  layout :layout_
  def welcome
    redirect_to '/users/sign_in' unless user_signed_in?
  end

  private
    def layout_
      if current_user.blank?
        'visitor'
      # elsif current_user.super_admin?
      #   'super_admin'
      # elsif current_user.admin?
      #   'admin'
      # elsif current_user.company.blank?
      #   'visitor'
      else
        'application'
      end
    end
end