class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_company

  layout :layout

  require 'pp'
  #处理控制器中的异常信息。
  def dispose_exception e
    case e
      when BusinessException
        return e.to_s
      when ActiveRecord::RecordInvalid #对于模型中的字段校验，则返回一个hash，分别是字段所对应的错误信息。
        errors = ''
        e.record.errors.each do |k, v|
          errors += v
        end
        return errors
      when ActiveRecord::RecordNotFound
        # e.to_s.to_logger
        # $@.to_logger
        return '记录未被找到'
      else
        # e.to_s.to_logger
        # $@.to_logger
        return '貌似有一些问题，请联系系统管理员，微信 mbeslow'
    end
  end

  def current_company
    current_user.company
  end



  private

  def layout
    # only turn it off for login pages:
    # is_a?(Devise::SessionsController) ? false : "application"
    # or turn layout off for every devise controller:
    devise_controller? ? 'visitor' : "application"
  end

end
