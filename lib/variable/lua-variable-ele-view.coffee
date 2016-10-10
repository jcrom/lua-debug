{$,$$, View} = require 'atom-space-pen-views'
VarEleLiView = require './variable-ele-li-view'


module.exports =
class VarEleView extends View
  oStoreView:{}

  @content: ->
    # @ul outlet:"tree_trunk", class:'vlist_ul'
    @div =>
      @ul class:'vlist_ul',outlet:'ul_list'


  initialize: (@oReList) ->
    # console.log @ul_list
    # console.log @oReList
    @oStoreView={}
    for sKey, sVal of @oReList
      # if typeof(sVal) isnt "object"
      #   console.log "isnt obj", sKey, sVal
      #   vEleView = new VarEleLiView(sKey, sVal)
      #   @ul_list.append vEleView
      #   # for sK, sV of sVal
      # else
      #   console.log "is obj", sKey, sVal
      vEleUlView = new VarEleLiView(sKey, sVal)
      @oStoreView[sKey] = @new_store_obj(sVal, vEleUlView)
      @ul_list.append vEleUlView

  destroy: ->
    @detach()

  new_store_obj: (val, vView) ->
    return {val:val, view:vView}



  create_ele_li:() ->
    vEleLi = document.createElement('li')
    vEleLi.classList.add('vlist_li', 'icon')


  refresh_variable:(oNewReList) ->
    for sOKey, sOVal of @oStoreView
      if not oNewReList[sOKey]
        sOVal.view.destroy()
        delete @oStoreView[sOKey]

    # console.log oNewReList
    for sKey, sVal of oNewReList
      # console.log sKey, sVal
      if oViewObj = @oStoreView[sKey]
          oViewObj.view.refresh_variable(sKey, sVal)

      else
        # @oStoreView[sKey]
        vEleUlView = new VarEleLiView(sKey, sVal)
        @oStoreView[sKey] = @new_store_obj(sVal, vEleUlView)
        @ul_list.append vEleUlView


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
