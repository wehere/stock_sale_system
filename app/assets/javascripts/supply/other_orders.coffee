@supplyOtherOrdersNew = ->
  $('body').on 'click', '#other_order_new_submit', ->
    if validateForm()
      $('#other_order_new_form').submit()

validateForm = ->
  quantity_arr = $('.product_items_quantity')
  return false if quantity_arr?.length is 0

  for quantity, index in quantity_arr
    if isBlank(quantity.value)
      renderFlash("第#{ index + 1 }行，请填写数量", 'alert')
      return false

  price_arr = $('.product_items_price')
  return false if price_arr?.length is 0

  for price, index in price_arr
    if isBlank(price.value)
      renderFlash("第#{ index + 1 }行，请填写价格", 'alert')
      return false

  true