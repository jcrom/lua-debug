{CompositeDisposable, Emitter} = require 'atom'
{$, $$, View,TextEditorView} = require 'atom-space-pen-views'
VarEleUlView = require './subview/variable-ele-ul-view'
TestV1 = require './subview/test-v1'

emp = require './global/emp'

module.exports = class LuaDebugVarView extends View

  @content: ->
    # local variable list
    @div outlet: 'vVarView', class: 'lua-debug-server-row', style:"display:inline;", =>
      @div class: "server-con panel-body padded", click:'show_var_view', =>
        @div outlet:'var_icon', class: "block conf-heading icon icon-triangle-right", "Variables"

      @div outlet:'var_list_panel', class: "server-con panel-body padded",style:"display:none;",  =>
        # @div class: "state-div-content", =>
        #   @label outlet:"vServerState", class: "debug-label-content", "--"
        @div class:'control-ol', outlet:'locv_tree'
          # @table class:'control-tab',outlet:'locv_tree'
          # @ul class:'vlist_ul',outlet:'locv_tree1'

  initialize:() ->
    console.log @locv_tree


  show_var_view:() ->
    console.log "show_var_view"

    if @var_list_panel.isVisible()
      @var_list_panel.hide()
      @var_icon.addClass('icon-triangle-right')
      @var_icon.removeClass('icon-triangle-down')
    else
      @var_list_panel.show()
      @var_icon.removeClass('icon-triangle-right')
      @var_icon.addClass('icon-triangle-down')

    @test()

  refresh_variable:(fFileName, sVariable) ->
    console.log fFileName, sVariable
    oRe = JSON.parse(sVariable)
    console.log oRe


  test:() ->
    a='{"a":1123,"c":10000,"b":2,"d": {"e":2,"f":1},"ff":"<function >"}'
    oRe = JSON.parse(a)
    console.log oRe
    # for sKey, sVal of oRe
    # console.log @locv_tree1
    vVarEleView = new VarEleUlView(oRe)
    @locv_tree.append vVarEleView
    # vView = new TestV1(3)
