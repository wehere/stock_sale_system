# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  # Specify a custom renderer if needed.
  # The default renderer is SimpleNavigation::Renderer::List which renders HTML lists.
  # The renderer can also be specified as option in the render_navigation call.
  #navigation.renderer = Your::Custom::Renderer

  # Specify the class that will be applied to active navigation items. Defaults to 'selected' 
  #navigation.selected_class = 'selected'

  # Specify the class that will be applied to the current leaf of
  # active navigation items. Defaults to 'simple-navigation-active-leaf'
  #navigation.active_leaf_class = 'simple-navigation-active-leaf'

  # Specify if item keys are added to navigation items as id. Defaults to true
  #navigation.autogenerate_item_ids = true

  # You can override the default logic that is used to autogenerate the item ids.
  # To do this, define a Proc which takes the key of the current item as argument.
  # The example below would add a prefix to each key.
  #navigation.id_generator = Proc.new {|key| "my-prefix-#{key}"}

  # If you need to add custom html around item names, you can define a proc that
  # will be called with the name you pass in to the navigation.
  # The example below shows how to wrap items spans.
  #navigation.name_generator = Proc.new {|name, item| "<span>#{name}</span>"}

  # Specify if the auto highlight feature is turned on (globally, for the whole navigation). Defaults to true
  #navigation.auto_highlight = true
  
  # Specifies whether auto highlight should ignore query params and/or anchors when 
  # comparing the navigation items with the current URL. Defaults to true 
  navigation.ignore_query_params_on_auto_highlight = false
  #navigation.ignore_anchors_on_auto_highlight = true
  
  # If this option is set to true, all item names will be considered as safe (passed through html_safe). Defaults to false.
  #navigation.consider_item_names_as_safe = false

  # Define the primary navigation
  navigation.items do |primary|
    # Add an item to the primary navigation. The following params apply:
    # key - a symbol which uniquely defines your navigation item in the scope of the primary_navigation
    # name - will be displayed in the rendered navigation. This can also be a call to your I18n-framework.
    # url - the address that the generated item links to. You can also use url_helpers (named routes, restful routes helper, url_for etc.)
    # options - can be used to specify attributes that will be included in the rendered navigation item (e.g. id, class etc.)
    #           some special options that can be set:
    #           :if - Specifies a proc to call to determine if the item should
    #                 be rendered (e.g. <tt>if: -> { current_user.admin? }</tt>). The
    #                 proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :unless - Specifies a proc to call to determine if the item should not
    #                     be rendered (e.g. <tt>unless: -> { current_user.admin? }</tt>). The
    #                     proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :method - Specifies the http-method for the generated link - default is :get.
    #           :highlights_on - if autohighlighting is turned off and/or you want to explicitly specify
    #                            when the item should be highlighted, you can set a regexp which is matched
    #                            against the current URI.  You may also use a proc, or the symbol <tt>:subpath</tt>.
    #
    primary.item :key_1, '价格', "/supply/prices", class: 'special', if: -> { true } do |sub_nav|
      sub_nav.item :key_1_10, '价格', "/supply/prices", if: -> { true }
      sub_nav.item :key_1_1, '给客户提供的价格', '/supply/prices/search', if: -> { true }
      # sub_nav.item :key_1_2, '新增价格', '/supply/prices/prepare_create_price', if: -> { true }
      sub_nav.item :key_1_3, '生成下一个月价格', '/supply/prices/generate_next_month', if: -> { true}
      # sub_nav.item :key_1_4, '用excel导入价格', '/supply/prices/import_prices_from_xls', if: -> { true}
      sub_nav.item :key_1_5, '导出价格', '/supply/prices/export_xls_of_prices', if: -> { true}
      # sub_nav.item :key_1_6, '进货价格', '/purchase/purchase_price', if: -> { true}
      # sub_nav.item :key_1_7, '更新进货价格', '/purchase/purchase_price/pre_update_price', if: -> { true}
      # sub_nav.item :key_1_8, '售出价格', '/supply/prices/show_price', if: -> { true}
      sub_nav.item :key_1_9, '价格比率补充', '/supply/prices/need_make_up', if: -> { true}
    end

    # Add an item which has a sub navigation (same params, but with block)
    primary.item :key_2, '产品', "/supply/products", class: 'special', if: -> { true} do |sub_nav|
      # Add an item to the sub navigation (same params again)
      sub_nav.item :key_2_5, '产品', "/supply/products", if: -> { true}
      sub_nav.item :key_2_1, '新增产品', "/supply/products/strict_new", if: -> { true}
      sub_nav.item :key_2_2, '导入产品', '/supply/products/import_products_from_xls', if: -> { true}
      sub_nav.item :key_2_3, '通用产品一览', '/supply/general_products', if: -> { true}
      sub_nav.item :key_2_4, '检测重复通用', '/supply/general_products/check_repeated', if: ->{true}

    end
    primary.item :key_10, '订单', "/supply/orders/got_orders", class: 'special', if: -> {true } do |sub_nav|
      sub_nav.item :key_10_1, '下订单', "/purchase/orders/dingyu_send_order", if: -> {true}
      sub_nav.item :key_10_2, '收到的订单', "/supply/orders/got_orders", if: -> {true}
      sub_nav.item :key_10_3, '发出的订单', "/supply/orders/send_out_orders", if: -> {true}
    end
    # You can also specify a condition-proc that needs to be fullfilled to display an item.
    # Conditions are part of the options. They are evaluated in the context of the views,
    # thus you can use all the methods and vars you have available in the views.
    primary.item :key_3, '出货单', "/supply/orders", class: 'special', if: -> { true} do |sub_nav|
      sub_nav.item :key_3_7, '出货单', "/supply/orders", if: -> { true}
      sub_nav.item :key_3_1, '没回来的单子', "/supply/orders/not_return", if: -> { true}
      sub_nav.item :key_3_2, '单据回来－快捷', "/supply/orders/pre_confirm_back_order", if: -> { true}
      sub_nav.item :key_3_3, '查询未录入数据单据', "/supply/orders/not_input", if: -> { true}
      sub_nav.item :key_3_4, '开始录入到货量', "/supply/orders/0/edit", if: -> { true}
      sub_nav.item :key_3_5, '搜索已送品项', '/supply/order_items/search', if: -> { true}
      sub_nav.item :key_3_6, '补充未输入价格的品项', '/supply/order_items/null_price', if: -> { true}
    end
    primary.item :key_4, '进货单', "/supply/purchase_orders", class: 'special', if: -> { true} do |sub_nav|
      sub_nav.item :key_4_2, '进货单', "/supply/purchase_orders", if: -> {true}
      sub_nav.item :key_4_1, '查询进货品项详细', '/supply/purchase_orders/search_item', if: -> {true}
    end
    primary.item :key_5, '客户', "/supply/customers", class: 'special', if: -> { true} do |sub_nav|
      sub_nav.item :key_5_3, '客户', "/supply/customers", if: -> { true}
      sub_nav.item :key_5_1, '单据类型管理', '/supply/order_types', if: -> { true}
      sub_nav.item :key_5_2, '卖家一览', '/supply/sellers', if: -> { true}
    end

    primary.item :key_6, '报表', "/supply/sheets", class: 'special', if: -> { true} do |sub_nav|
      sub_nav.item :key_6_3, '报表', "/supply/sheets", if: -> { true}
      sub_nav.item :key_6_1, '分菜', '/supply/order_items/prepare_classify', if: -> { true}
      sub_nav.item :key_6_2, '产品清单', '/supply/products/prepare_export_products', if: -> { true}
    end
    primary.item :key_7, '库存', "/supply/stocks", class: 'special', if: -> { true} do |sub_nav|
    end
    primary.item :key_8, '配置', '/supply/i/config_', class: 'special', if: -> { true} do |sub_nav|

    end
    primary.item :key_9, '下载', '/supply/downloads', class: 'special', if: -> { true} do |sub_nav|

    end
    # you can also specify html attributes to attach to this particular level
    # works for all levels of the menu
    #primary.dom_attributes = {id: 'menu-id', class: 'menu-class'}

    # You can turn off auto highlighting for a specific level
    #primary.auto_highlight = false
  end
end
