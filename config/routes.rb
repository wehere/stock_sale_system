Rails.application.routes.draw do

  namespace :ding do
    resources :scores
  end

  get 'dingtalk/upload_score'

  get 'dingtalk/jxc_score_ding'

  devise_for :users, controllers: { sessions: 'users/sessions' }
  root to: 'vis/static_pages#welcome'

  require 'sidekiq/web'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == '549174542@qq.com' && password == 'jiaren123456'
  end if Rails.env.production?

  mount Sidekiq::Web => '/sidekiq'

  # 超级管理员
  namespace :sp do
    resources :companies
    resources :users do
      collection do
        get :link_company
        post :link_company
        get :set_role
        post :set_role
      end
    end
  end

  namespace :admin do

  end

  # 供应方
  namespace :supply do

    resources :month_inventories, only: [:index]

    resources :employee_foods do
      collection do
        get :add_it
        get :delete_it
      end
    end

    resources :downloads do
      collection do
        get :download
        post :delete_file
      end
    end
    resources :i do
      collection do
        get :config_
        post :delete_mark
        post :add_mark
        post :delete_vendor
        post :add_vendor
      end
    end
    resources :stocks
    resources :sellers do
      collection do
        get :prepare_set_general_products
        post :do_set_general_products
        get :up
        get :down
      end
    end
    resources :purchase_orders do
      collection do
        get :create_purchase_order
        post :create_purchase_order
        post :query_product_by_abc
        post :get_price_by_product_name

        get :change_order_item
        get :search_item
      end
      member do
        get :edit_seller
        post :update_seller
      end
    end
    resources :loss_orders do
      collection do
        get :create_loss_order
        post :create_loss_order
        post :query_product_by_abc
        post :get_price_by_product_name

        get :change_order_item
        get :search_item
      end
    end
    resources :general_products do
      collection do
        get :check_repeated
        get :prepare_link_to_seller
        post :do_link_to_seller
        get :complex
        post :save_g_p_mini_spec
        post :save_price_true_spec
        post :save_price_ratio
        post :save_purchase_price_true_spec
        post :save_purchase_price_ratio
        get :common_complex
        post :change_pass_status
        post :vendor
      end
    end
    resources :customers do
      collection do
        get :add_store
        post :add_store
        get :add_order_type
        post :add_order_type
        get :add_notice
        post :add_notice
      end
    end
    resources :sheets do
      collection do
        post :export_order_total_for_specified_days
        post :export_order_total_for_specified_month
        post :export_purchase_order
        post :export_stocks
        post :export_product_in_out
        post :export_total_day_money_by_vendor
        post :export_total_day_money_by_seller
        post :export_product_list_by_store
      end
      member do
        post :change_stores
      end
    end
    resources :home, only: [:index]
    resources :products, only: [:index, :new, :update, :edit, :show] do
      collection do
        get :prepare_link_to_general_product
        post :do_link_to_general_product
        post :create_one
        get :import_products_from_xls
        post :import_products_from_xls
        get :strict_new
        get :change_sub_spec
        post :strict_create
        get :strict_edit
        post :strict_update
        post :mark
        post :export_products
        get :prepare_export_products
        get :detail
        get :soft_delete
        get :change_sale_ratio
        post :change_sale_ratio
        get :update_sale_ratio_by_mark
        post :update_sale_ratio_by_mark
        post :force_update_sale_ratio_by_mark
        get :go
        get :disabled_products
        get :remove_disable
      end
    end
    resources :prices do
      collection do
        get :need_make_up
        get :index
        get :search
        post :search
        get :generate_next_month
        post :generate_next_month
        get :import_prices_from_xls
        post :import_prices_from_xls
        get :export_xls_of_prices
        post :update_one_price
        get :show_price
        post :save_data
        get :prepare_create_price
      end
      member do
        get :do_not_use
        post :export_xls_of_prices
        post :true_update_price
      end
    end
    resources :orders do
      collection do
        post :save_real_price
        post :comment
        get :not_input
        post :not_input
        get :return
        get :not_return
        get :pre_confirm_back_order
        post :confirm_back_order
        get :got_orders
        get :send_message_dealt
        get :send_out_orders
        get :send_out_order_delete
      end
      member do
        get :return
      end
    end
    resources :order_types, only: [:index, :create, :destroy, :new]
    resources :order_items do
      collection do
        post :search
        get :search
        get :null_price
        get :prices_search
        get :prepare_classify
        post :do_classify
      end
      member do
        post :change_delete_flag
        get :change_delete_flag
      end
    end

    resources :checks

    resources :other_orders
  end

  # 游客
  namespace :vis do
    resources :static_pages do
      collection do
        get :welcome
      end
    end
  end

  # 采购方
  namespace :purchase do
    resources :home, only: [:index]
    resources :products
    resources :prices do
      collection do
        get :search
        post :search

      end
    end
    resources :purchase_price do
      collection do
        post :save_data
        get :pre_update_price
        get :update_price
      end
    end
    resources :orders do
      collection do
        post :send_message
        post :index
        post :comment
        post :dingyu_send_order
        get  :dingyu_send_order
        post :get_spec_by_product_name
        post :query_product_by_abc
        post :send_message
      end
    end

    resources :employee_foods do
      collection do
        post :send_employee_food_order
      end
    end
  end
end
