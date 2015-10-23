class Purchase::ProductsController < ApplicationController
  def index

  end

  def create
    begin
      product = Product.new product_params
      product.save!
      flash[:notice] = "创建成功"
      redirect_to new_sp_product_path
    rescue Exception => e
      flash[:alert] = dispose_exception e
      @product = product
      render new_sp_product_path
    end
  end

  def new
    @product = Product.new
  end

  private
    def product_params
      params.require(:product).permit([:english_name,:chinese_name,:spec,:simple_abc])
    end
end