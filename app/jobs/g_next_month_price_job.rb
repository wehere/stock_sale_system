class GNextMonthPriceJob < ApplicationJob
  queue_as :default

  def perform(supplier_id)
    Price.g_next_month_price YearMonth.current_year_month.id, YearMonth.next_year_month.id, supplier_id
  end
end
