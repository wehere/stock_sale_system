namespace :price do
  desc "生成下个月价格"
  task :generate_next_month_price do
    sc = SystemConfig.find_by_k('generate_price_count')
    if sc.present?
      sc.update_attributes(v: SystemConfig.v('generate_price_count', 0).to_i + 1)
    else
      SystemConfig.create! k: 'generate_price_count', v: '0'
    end
    YearMonth.delay.generate_recent_year_months
    Company.all_suppliers.each do |supplier|
      Price.delay.g_next_month_price YearMonth.current_year_month.id, YearMonth.next_year_month.id, supplier.id
    end
  end
end
