$(document).on "turbolinks:load", ->
  $(document).foundation()

  # 关闭flash
  closeMessage()

@renderFlash = (msg, type) ->
  color = if type in 'notice success'.split(' ') then '#43ac6a' else '#f04124'
  str = '<div class="alert callout ys-layout-message" data-closable style="background-color: ' + color + '">'
  str += '<div><span>' + msg + '</span></div>'
  str += '<button class="close-button" aria-label="Dismiss alert" type="button" id="flash_close_button" data-close>'
  str += '<span aria-hidden="true">&times;</span>'
  str += '</button>'
  str += '</div>'

  $("#ys-layout-message").html(str)
  closeMessage()

@closeMessage = ->
  setTimeout ->
    $("#flash_close_button").click()
  , 5000