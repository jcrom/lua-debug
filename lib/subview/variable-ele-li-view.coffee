{$, $$, $$$, View} = require 'atom-space-pen-views'
# VarEleUlView = require './variable-ele-ul-view'

module.exports =
class VarEleLiView extends View

  @content: (sKey, sVal) ->
    @div =>
      @li outlet: 'li_view', class: 'vlist_li icon ', =>
        if typeof(sVal) isnt "object"
          @span class:'text-warning', "#{sKey} "
          @span class:'text-info', " = #{sVal}"
        else
          @span class:'text-warning', "#{sKey} "
          @span class:'text-info', " = Table"

  initialize: (@sKey, @sVal, VarEleUlView) ->
    # console.log @li_view
    console.log @sVal
    if typeof(@sVal) is "object"
      console.log "is obj"
      vUlView = new VarEleUlView(@sVal)
      console.log vUlView
      @li_view.after vUlView

  destroy: ->
    @detach()
