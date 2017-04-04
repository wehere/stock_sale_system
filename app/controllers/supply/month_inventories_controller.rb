class Supply::MonthInventoriesController < BaseController
  def index
    params[:year_month_id] ||= YearMonth.current_year_month.id
    @month_inventories = MonthInventory.where(year_month_id: params[:year_month_id]||YearMonth.current_year_month.id)
    .where(supplier_id: current_user.company.id)
    .order(updated_at: :desc)
    @year_months = YearMonth.where('value >= 201603').order(:value)
  end
end
