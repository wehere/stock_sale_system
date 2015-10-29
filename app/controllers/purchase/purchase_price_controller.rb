class Purchase::PurchasePriceController < BaseController

  before_filter :need_login

  def index
    @prices = PurchasePrice.query_purchase_price is_used: true,
                                                 product_name: params[:product_name],
                                                 supplier_id: current_user.company.id,
                                                 per_page: 10,
                                                 page: params[:page]

    @seller = current_user.company.sellers.where(delete_flag: false).order(sort_number: :desc)
  end

  def save_data
    permitted = params.permit(p: [:seller_id, :price, :ratio, :true_spec])
    params.permit(:id)
    purchase_price = PurchasePrice.find params[:id]
    # result = begin
      new_purchase_price = purchase_price.update_purchase_price permitted[:p]

      result = {
          :code => 0,
          :status => '存储数据成功',
          :seller_name => new_purchase_price.seller.name,
          :price => new_purchase_price.price,
          :true_spec => new_purchase_price.true_spec,
          :ratio => new_purchase_price.ratio
      }
    # rescue Exception => e
    #   {:code => 1,
    #    :status => '失败'}
    # end
    render :json => result.to_json
  end


  private
  def price_params
    params.permit([:p])
  end
end
