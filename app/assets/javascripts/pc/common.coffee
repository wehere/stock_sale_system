$(document).on "turbolinks:load", ->
  $(document).foundation()

  # 关闭flash
  closeMessage()

  initNamespaceFunction()

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

#
# JS命名空间 (为javascript 执行隔离编写)
#

#
# 通过函数名(字符串) 执行函数
# 并使用驼峰命名解析
#
# @method execFunc
# @param {String} 函数名
#
@execFunc = (name) -> executeFunction(camelCase(name), null)

#
# 通过函数名(字符串) 执行函数
#
# @method  executeFunction
# @param {String} name 要执行的函数名
# @param {Array} params 要执行的函数的参数数组，可以不填写
#
# @returns {Undefined} 执行结果 ，如果该函数不存在返回 Undefined
#
executeFunction = (name, params) ->
  fun = window[name]

  return fun.apply(null, params) if fun? and typeof fun is 'function'

#
# 将使用下划线分割单词的函数名
# 转换成驼峰命名
#
# @method camelCase
# @param {String} name 函数名
#
# @returns {String} 修改后的函数名
#
@camelCase = (name) ->

  return name if typeof name is 'undefined'

  name = name.replace(/-\w/g, ($1) -> $1.toLocaleUpperCase())

  name.replace(/-/g, '')

#
# 初始化执行 javascript 命名空间隔离的函数
#
# @method initNamespaceFunction
#
@initNamespaceFunction = ->
  body = document.body

  idFunction = body.id
#  classFunction = body.classList[0]

  execFunc(idFunction)
#  execFunc(classFunction)

#
# 判断对象是否定义/非Null/非空字符串/非空数组/非空对象
#
@isPresent = (obj) ->
  not isBlank(obj)

#
# 判断对象是否未定义/Null/空字符串/空数组/空对象
#
@isBlank = (obj) ->
  type = Object.prototype.toString.call(obj)

  switch type
    when '[object Null]' then true
    when '[object Undefined]' then true
    when '[object Boolean]' then !obj
    when '[object String]' then _.trim(obj) is ''
    when '[object Array]' then obj.length <= 0
    when '[object Number]' then false
    when '[object Object]' then Object.keys(obj).length is 0
    when '[object Function]' then false
    else false
