class OrderDetail < ActiveRecord::Base


  def self.write_stock_from_start_to_end
    self.transaction do

    end
  end
end