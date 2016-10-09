{$,$$, View} = require 'atom-space-pen-views'
VarEleLiView = require './subview/variable-ele-li-view'


module.exports =
class VarEleView extends View
  @content: ->
    # @ul outlet:"tree_trunk", class:'vlist_ul'
    @div =>
      @ul class:'vlist_ul',outlet:'ul_list'


  initialize: (@oReList) ->
    # console.log @ul_list
    console.log @oReList
    for sKey, sVal of @oReList
      # if typeof(sVal) isnt "object"
      #   console.log "isnt obj", sKey, sVal
      #   vEleView = new VarEleLiView(sKey, sVal)
      #   @ul_list.append vEleView
      #   # for sK, sV of sVal
      # else
      #   console.log "is obj", sKey, sVal
      vEleUlView = new VarEleLiView(sKey, sVal)
      @ul_list.append vEleUlView

  destroy: ->
    @detach()


  create_ele_li:() ->
    vEleLi = document.createElement('li')
    vEleLi.classList.add('vlist_li', 'icon')


  ex: ->
    $$ ->
      @li outlet: 'li_view', class: 'vlist_li icon ', =>
        if typeof(sVal) isnt "object"
          @span class:'text-warning', "#{sKey} "
          @span class:'text-info', " = #{sVal}"
        else
          @span class:'text-warning', "#{sKey} "
          @span class:'text-info', " = Table"

  # format_list: (tmpK, tmpV)->
  #   $$ ->
  #     @li outlet: 'ele_name', class: 'vlist_li icon ', =>
  #       if typeof(tmpV) isnt "object"
  #         @span class:'text-warning', "#{tmpK} "
  #         @span class:'text-info', " = #{tmpV}"
  #       else
  #         @span class:'text-warning', "#{tmpK} "
  #         @span class:'text-info', " = Table"
  #         @ul class:'vlist_ul', =>
  #           for sK, sV of tmpV
  #             @format_list(sK, sV)

  # del_dp: ->
  #   @callback(@oBreakpoint)
  #   @detach()
