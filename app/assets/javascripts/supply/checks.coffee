# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@supplyChecksNew = ->
  initCheck()

@supplyChecksEdit = ->
  initCheck()

initCheck = ->
  $('body').on 'change', '.check_items_quantity', ->
    checkDiff($(this))

  $('body').on 'click', '#draft_check', ->
    $("#check_status").val('draft')
    $('#check_form').submit()

  $('body').on 'click', '#submit_check', ->
    if validateForm()
      $("#check_status").val('submitted')
      $('#check_form').submit()

  $('body').on 'click', '.delete_check_item', ->
    gp_id = $(this).data('gpid')
    $("#tr_#{gp_id}").html('')
    $("#check_check_items_attributes_#{gp_id}__destroy").val(true)

initCheckDiff = ->
  quantity_arr = $('.check_items_quantity')
  return false if quantity_arr?.length is 0

  for quantity in quantity_arr
    checkDiff(quantity)

checkDiff = (element) ->
  gp_id = element.data('gpid')
  stock_quantity = parseFloat($("#check_item_real_weight_#{ gp_id }").html())
  check_quantity = parseFloat(element.val())
  console.log stock_quantity
  diff = if isNaN(stock_quantity) or isNaN(check_quantity)
    ''
  else
    check_quantity - stock_quantity
  $("#check_item_diff_#{ gp_id }").html(diff)

validateForm = ->
  quantity_arr = $('.check_items_quantity')
  return false if quantity_arr?.length is 0

  for quantity, index in quantity_arr
    if isBlank(quantity.value)
      renderFlash("第#{ index + 1 }行，请填写实际库存数量", 'alert')
      return false

  true