namespace :month_inventory do
  desc "复制月库存记录"
  task :copy => :environment do
    if Time.now.to_date == Time.now.beginning_of_month.to_date
      MonthInventory.copy_month_inventory
    end
  end
end
