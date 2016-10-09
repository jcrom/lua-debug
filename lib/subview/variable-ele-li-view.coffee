{$, $$, $$$, View} = require 'atom-space-pen-views'
# VarEleUlView = require './variable-ele-ul-view'

module.exports =
class VarEleLiView extends View

  @content: (sKey, sVal) ->
    if typeof(sVal) isnt "object"
      @li outlet: 'li_view', class: 'vlist_li icon ', =>
          @span class:'text-warning', "#{sKey} "
          @span class:'text-info', " = #{sVal}"
    else
      @li class: 'vlist_li', =>
        @div outlet: 'li_view', class:'icon icon-triangle-right', click:'show_var_detail', =>
          @span class:'text-warning', "#{sKey} "
          @span class:'text-info', " = Table"
        @ul class:'vlist_ul',outlet:'ul_list', style:"display:none;"

  initialize: (@sKey, @sVal) ->
    console.log @li_view
    console.log @sVal
    if typeof(@sVal) is "object"
      console.log "is obj"

      for sTmpKey, sTmpVal of @sVal
        # if typeof(sTmpVal) isnt "object"
        # console.log "isnt obj", sKey, sVal
        vEleView = new VarEleLiView(sTmpKey, sTmpVal)
        @ul_list.append vEleView
      # vUlView = new VarEleLiView(@sVal)
      # console.log vUlView
      # @li_view.after vUlView

  destroy: ->
    @detach()

  show_var_detail:() ->
    console.log "show_var_view"

    if @ul_list.isVisible()
      @ul_list.hide()
      @li_view.addClass('icon-triangle-right')
      @li_view.removeClass('icon-triangle-down')
    else
      @ul_list.show()
      @li_view.removeClass('icon-triangle-right')
      @li_view.addClass('icon-triangle-down')
