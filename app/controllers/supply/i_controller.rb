class Supply::IController < BaseController
  before_filter :need_login
  def config_
    @company = current_user.company
  end

  def delete_mark
    company = current_user.company
    products = Product.where(supplier_id: company.id, mark: params[:mark])
    if products.blank?
      a = company.marks.split(",")
      a.delete(params[:mark])
      company.update_attribute :marks, a.join(",")
      render text: 'ok'
    else
      render text: "#{params[:mark]}已经在使用中，不可以删除。"
    end
  end

  def add_mark
    if params[:mark].blank?
      render text: '请先填写分类'
      return
    end
    company = current_user.company
    marks_array = company.marks.split(",")
    if marks_array.include? params[:mark]
      render text: "已经存在#{params[:mark]}"
    else
      marks_array << params[:mark]
      company.update_attribute :marks, marks_array.join(",")
      render text: "ok"
    end
  end

  def delete_vendor
    company = current_user.company
    general_products = GeneralProduct.where(supplier_id: company.id, vendor: params[:vendor])
    if general_products.blank?
      a = company.vendors.split(",")
      a.delete(params[:vendor])
      company.update_attribute :vendors, a.join(",")
      render text: 'ok'
    else
      render text: "#{params[:vendor]}已经在使用中，不可以删除。"
    end
  end

  def add_vendor
    if params[:mark].blank?
      render text: '请先填写商贩'
      return
    end
    company = current_user.company
    vendors_array = company.vendors.split(",")
    if vendors_array.include? params[:vendor]
      render text: "已经存在#{params[:vendor]}"
    else
      vendors_array << params[:vendor]
      company.update_attribute :vendors, vendors_array.join(",")
      render text: "ok"
    end
  end
end