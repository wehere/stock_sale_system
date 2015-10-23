class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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
        return '发生未知错误'
    end
  end

end
