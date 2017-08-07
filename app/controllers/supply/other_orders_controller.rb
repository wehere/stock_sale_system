class Supply::OtherOrdersController < BaseController

  before_action :need_admin, only: [:new, :create, :destroy]

  def index
    @title = '盘盈盘亏列表'
    @other_orders = current_company.other_orders.query_by(params.permit(:start_date, :end_date, :category))
    @total_amount = @other_orders.sum(:total_amount).round(2)
    @other_orders = @other_orders.order(updated_at: :desc).paginate(per_page: 10, page: params[:page])

  end

  def new
    @category = params[:category]
    @category_i18n = OtherOrder.categories_i18n[@category]
    @title = "生成#{@category_i18n}单"
    @check = Check.find(params[:check_id])

    @check_items = @check.check_items.where(check_item_type: @category)

    product_items = @check_items.map do |check_item|
      {
          supplier: @check.supplier,
          general_product: check_item.general_product,
          product_name: check_item.product_name,
          quantity: check_item.profit_or_loss,
          unit: check_item.unit,
          price: check_item.general_product.current_purchase_price,
      }
    end
    options = {
        supplier: @check.supplier,
        storage_id: @check.storage_id,
        check_id: @check.id,
        category: @category,
        io_at: @check.checked_at,
    }
    @other_order = current_company.other_orders.new(options)
    @other_order.product_items.build(product_items)
    # pp @other_order
    # pp @other_order.product_items
  end

  def create
    @other_order = OtherOrder.new other_order_params.merge(creator_id: current_user.id)
    if @other_order.save
      flash[:success] = '提交成功'
    else
      flash[:alert] = "提交失败,#{@other_order.errors.messages.values.flatten.first}"
    end
  end

  def show
    @title = '单据详情'
    @other_order = current_company.other_orders.find(params[:id])
  end

  def edit
  end

  def update
  end

  def destroy
    @other_order = current_company.other_orders.find(params[:id])
    if @other_order.destroy
      flash[:success] = '删除成功'
    else
      flash[:alert] = "删除失败，#{@other_order.errors.messages.values.flatten.first}"
    end
    redirect_to action: :index
  end

  private

  def other_order_params
    params.require(:other_order).permit(:id, :supplier_id, :storage_id, :check_id, :io_at, :category, :note,
                                        product_items_attributes: [:id, :supplier_id, :other_order_id, :general_product_id,
                                        :product_name, :quantity, :unit, :price, :amount, :_destroy])
  end
end
