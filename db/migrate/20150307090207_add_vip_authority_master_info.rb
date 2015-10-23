class AddVipAuthorityMasterInfo < ActiveRecord::Migration
  def change
    execute  "INSERT INTO `vip_authorities` (`vip_type`, `customer_count`, `print_able_per_day_count`, `product_count`) VALUES (0, 2,100,200);"
    execute  "INSERT INTO `vip_authorities` (`vip_type`, `customer_count`, `print_able_per_day_count`, `product_count`) VALUES (1,20,500,500);"
    execute  "INSERT INTO `vip_authorities` (`vip_type`, `customer_count`, `print_able_per_day_count`, `product_count`) VALUES (2,99999,9999999,99999999);"
  end
end
