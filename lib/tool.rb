class BusinessException < Exception
  def self.raise exception_message
    # $!.to_s.to_logger
    # $@.to_logger if $@
    Kernel.raise BusinessException, exception_message
  end
end