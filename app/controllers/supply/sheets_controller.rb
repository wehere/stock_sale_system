class Supply::SheetsController < BaseController
  before_filter :need_login

  def index
    @start_date = Time.now.to_date.last_month.beginning_of_month
    @end_date = Time.now.to_date.last_month.end_of_month
    @customers = current_user.company.customers.order(:simple_name)
    @customer_id = @customers.first.id
    @stores = @customers.first.stores
    @store_id = @stores.first.id
  end

  def change_stores
    @stores = Company.find(params[:id]).stores
    @store_id = @stores.first.id
  end

  def export_order_total_for_specified_days
    begin
      supplier_id = current_user.company.id
      file_name = Order.export_order_total_for_specified_days params[:start_date].to_date, params[:end_date].to_date,
                                                              params[:customer_id], supplier_id, params[:store_id]
      if File.exists? file_name
        io = File.open(file_name)
        io.binmode
        send_data io.read, filename: file_name, disposition: 'inline'
        io.close
        File.delete file_name
      else
        flash[:alert] = '文件不存在！'
        redirect_to supply_sheets_path
      end
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      redirect_to supply_sheets_path
    end
  end

  def export_order_total_for_specified_month
    supplier_id = current_user.company.id
    file_name = Order.export_order_total_for_specified_month params[:start_date], params[:end_date], supplier_id
    if File.exists? file_name
      io = File.open(file_name)
      io.binmode
      send_data io.read, filename: file_name, disposition: 'inline'
      io.close
      File.delete file_name
    else
      flash[:alert] = '文件不存在!'
      redirect_to supply_sheets_path
    end
  end

end