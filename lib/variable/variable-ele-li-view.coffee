{$, $$, $$$, View} = require 'atom-space-pen-views'
# VarEleUlView = require './variable-ele-ul-view'

module.exports =
class VarEleLiView extends View
  oStoreView:{}
  @content: (sKey, sVal) ->
    if typeof(sVal) isnt "object"
      @li outlet: 'li_view', class: 'vlist_li icon ', =>
          @span class:'text-warning', "#{sKey} "
          @span class:'text-info', " = "
          @span outlet:'vSpanVal', class:'text-info', "#{sVal}"
    else
      @li class: 'vlist_li', =>
        @div outlet: 'li_view', class:'icon icon-triangle-right', click:'show_var_detail', =>
          @span class:'text-warning', "#{sKey} "
          @span class:'text-info', " = "
          @span outlet:'vSpanVal', class:'text-info', "Table"
        @ul class:'vlist_ul',outlet:'ul_list', style:"display:none;"

  initialize: (@sKey, @sVal) ->
    # console.log @vSpanVal.text()
    # console.log @sVal
    @oStoreView={}
    if typeof(@sVal) is "object"
      # console.log "is obj"

      for sTmpKey, sTmpVal of @sVal
        # if typeof(sTmpVal) isnt "object"
        # console.log "isnt obj", sKey, sVal
        vEleView = new VarEleLiView(sTmpKey, sTmpVal)
        @oStoreView[sTmpKey] = @new_store_obj(sTmpVal, vEleView)
        @ul_list.append vEleView
      # vUlView = new VarEleLiView(@sVal)
      # console.log vUlView
      # @li_view.after vUlView

  destroy: ->
    @detach()

  new_store_obj: (val, vView) ->
    return {val:val, view:vView}

  show_var_detail:() ->
    # console.log "show_var_view"

    if @ul_list.isVisible()
      @ul_list.hide()
      @li_view.addClass('icon-triangle-right')
      @li_view.removeClass('icon-triangle-down')
    else
      @ul_list.show()
      @li_view.removeClass('icon-triangle-right')
      @li_view.addClass('icon-triangle-down')

  refresh_variable:(sNKey, sNVal) ->
    # console.log "refresh li:", sNKey, sNVal
    if typeof(sNVal) is 'object'

      for sOKey, sOVal of @oStoreView
        if not sNVal[sOKey]
          sOVal.view.destroy()
          delete @oStoreView[sOKey]

      for sNewSubK, sNewSubV of sNVal
        if oViewObj = @oStoreView[sNewSubK]
          oViewObj.view.refresh_variable(sNewSubK, sNewSubV)

        else
          vEleUlView = new VarEleLiView(sNewSubK, sNewSubV)
          @oStoreView[sNewSubK] = @new_store_obj(sNewSubV, vEleUlView)
          @ul_list.append vEleUlView

      @sVal = sNVal

    else if sNVal isnt @sVal
      # console.log @vSpanVal
      @sVal = sNVal
      @vSpanVal.text(@sVal)
      # @vSpanVal  oStoreView:{}
