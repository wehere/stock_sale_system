class BusinessException < Exception
  def self.raise exception_message
    # $!.to_s.to_logger
    # $@.to_logger if $@
    Kernel.raise BusinessException, exception_message
  end
end

module Tools
  #给定数字和长度，不够在前边补0
  def self.get_number_with_0 number, length
    zero_number = length - "#{number}".length
    "#{"0"*zero_number}#{number}"
  end


  def self.distance_of_time_in_words t
    seconds = (Time.new.to_i - t.to_i).floor
    case
      when seconds < 25.seconds
        "刚刚"
      when seconds < 31.seconds
        "半分钟前"
      when seconds < 1.minute
        "少于1分钟前"
      when seconds < 2.minutes
        "1分钟前"
      when seconds < 45.minutes
        "#{seconds/1.minute}分钟前"
      when seconds < 59.minutes
        "少于1小时前"
      when seconds < 120.minutes
        "1小时前"
      when seconds < 18.hours
        "#{(seconds / 1.hour).round}小时前"
      when seconds < 48.hours
        "昨天"
      when seconds < 6.days
        "#{(seconds / 1.day).round}天前"
      when seconds < 1.week
        "1周前"
      when seconds < 28.days
        "#{(seconds / 1.week).round}周前"
      when seconds < 30.days
        "1个月前"
      when seconds < 364.days
        "#{(seconds / 1.month).round}月前"
      when seconds <= 365.days
        "1年前"
      when seconds < 5.years
        "#{(seconds / 1.year).round}年前"
      else
        "#{seconds / 1.minute}分钟前"
    end
  end

end