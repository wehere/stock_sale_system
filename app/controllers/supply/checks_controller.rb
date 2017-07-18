class Supply::ChecksController < BaseController

  before_action :need_login

  def index
    @title = '盘点列表'
    @checks = current_company.checks.order(updated_at: :desc).paginate(per_page: 10, page: params[:page])
  end

  def new
    @title = '新增盘点'
    params[:checked_at] ||= Date.today
    @supplier = current_user.company
    @check = Check.new
    @storages = @supplier.storages
    @categories = @supplier.categories

    @general_products = @supplier.general_products.is_valid

    if params[:category].blank? && params[:name].blank?
      @general_products = @general_products.none
    else

      if params[:category].present?
        @general_products = @general_products.joins(:products).where(products: {mark: params[:category]})
      end

      if params[:name].present?
        @general_products = @general_products.where('general_products.name like ? ', "%#{params[:name]}%")
      end

    end
  end

  def edit
    @title = '正在盘点'
    @check = current_company.checks.find(params[:id])
  end

  def show
    @title = '盘点详情'
    @check = current_company.checks.find(params[:id])
    @has_profit = @check.check_items.profit.any?
    @has_loss = @check.check_items.loss.any?
  end

  def create
    if check_params[:status] == 'submitted'
      need_admin
    end
    @check = Check.new check_params.merge(storage_id: current_user.store.storage.id, creator_id: current_user.id, supplier_id: current_company.id)
    if @check.save(validate: check_params[:status] == 'submitted')
      flash[:success] = "保存为#{@check.status_i18n}成功"
    else
      flash[:alert] = "保存为#{@check.status_i18n}失败,#{@check.errors.messages.values.flatten.first}"
    end
  end

  def update
    if check_params[:status] == 'submitted'
      need_admin
    end
    @check = current_company.checks.find(params[:id])
    @check.assign_attributes check_params.merge(creator_id: current_user.id)
    if @check.save(validate: check_params[:status] == 'submitted')
      @notice = "保存为#{@check.status_i18n}成功"
    else
      @error = "保存为#{@check.status_i18n}失败,#{@check.errors.messages.values.flatten.first}"
    end
  end

  def destroy
    @check = current_company.checks.draft.find(params[:id])
    if @check.destroy
      flash[:success] = '删除成功'
    else
      @error = "删除失败,#{@check.errors.messages.values.flatten.first}"
    end
  end

  private

  def check_params
    params.require(:check).permit(:category, :status, :checked_at,
                                  check_items_attributes: [:id, :general_product_id, :product_name, :unit, :storage_quantity,
                                  :quantity, :note, :_destroy]
    )
  end
end
