class Supply::SheetsController < BaseController
  before_filter :need_login

  def index
    @start_date = Time.now.to_date.last_month.beginning_of_month
    @end_date = Time.now.to_date.last_month.end_of_month
    @customers = current_user.company.now_customers.order(:simple_name)
    @customer_id = @customers.first.id rescue ''
    @stores = @customers.first.stores rescue ''
    @store_id = @stores.first.id rescue ''
  end

  def change_stores
    @stores = Company.find(params[:id]).stores
    @store_id = @stores.first.id
  end

  def export_order_total_for_specified_days
    # begin
      supplier_id = current_user.company.id

      ExportOrderTotalForSpecifiedDaysJob.perform_later params[:start_date],
                                                      params[:end_date],
                                                      params[:customer_id],
                                                      supplier_id,
                                                      params[:store_id]

      flash[:notice] = "正在下载，下载完毕后，您可以在下载页看到您需要的文件"
      redirect_to action: :index
    #   if File.exists? file_name
    #     io = File.open(file_name)
    #     io.binmode
    #     send_data io.read, filename: file_name, disposition: 'inline'
    #     io.close
    #     File.delete file_name
    #   else
    #     flash[:alert] = '文件不存在！'
    #     redirect_to supply_sheets_path
    #   end
    # rescue Exception=>e
    #   flash[:alert] = dispose_exception e
    #   redirect_to supply_sheets_path
    # end
  end

  def export_order_total_for_specified_month
    supplier_id = current_user.company.id
    ExportOrderTotalForSpecifiedMonthJob.perform_later(params[:start_date], params[:end_date], supplier_id)
    flash[:notice] = "正在下载，下载完毕后，您可以在下载页看到您需要的文件"
    redirect_to action: :index
    # if File.exists? file_name
    #   io = File.open(file_name)
    #   io.binmode
    #   send_data io.read, filename: file_name, disposition: 'inline'
    #   io.close
    #   File.delete file_name
    # else
    #   flash[:alert] = '文件不存在!'
    #   redirect_to supply_sheets_path
    # end
  end

  def export_purchase_order
    supplier_id = current_user.company.id
    ExportPurchaseOrderJob.perform_later params[:start_date], params[:end_date], supplier_id
    flash[:notice] = "正在下载，下载完毕后，您可以在下载页看到您需要的文件"
    redirect_to action: :index
    # send_file file_name
  end

  def export_stocks
    supplier_id = current_user.company.id
    ExportStocksJob.perform_later params[:start_date], params[:end_date], supplier_id
    flash[:notice] = "正在下载，下载完毕后，您可以在下载页看到您需要的文件"
    redirect_to action: :index
  end

  def export_product_in_out
    supplier_id = current_user.company.id
    ExportProductInOutJob.perform_later params[:start_date], params[:end_date], supplier_id
    flash[:notice] = "正在下载，下载完毕后，您可以在下载页看到您需要的文件"
    redirect_to action: :index
  end

  def export_total_day_money_by_vendor
    supplier_id = current_user.company.id
    ExportTotalDayMoneyByVendorJob.perform_later params[:start_date], params[:end_date], supplier_id
    flash[:notice] = "正在下载，下载完毕后，您可以在下载页看到您需要的文件"
    redirect_to action: :index
  end

  def export_total_day_money_by_seller
    supplier_id = current_user.company.id
    ExportTotalDayMoneyBySellerJob.perform_later params[:start_date], params[:end_date], supplier_id
    flash[:notice] = "正在下载，下载完毕后，您可以在下载页看到您需要的文件"
    redirect_to action: :index
  end

  def export_product_list_by_store
    supplier_id = current_user.company.id
    ExportProductListByStoreJob.perform_later supplier_id, params[:store_id]
    flash[:notice] = "正在下载，下载完毕后，您可以在下载页看到您需要的文件"
    redirect_to action: :index
  end
end
