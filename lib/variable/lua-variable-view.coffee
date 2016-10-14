{CompositeDisposable, Emitter} = require 'atom'
{$, $$, View,TextEditorView} = require 'atom-space-pen-views'
# VarEleUlView = require './subview/variable-ele-ul-view'

VarEleView = require './lua-variable-ele-view'

emp = require '../global/emp'

module.exports = class LuaDebugVarView extends View

  @content: (sViewName)->
    # local variable list
    @div outlet: 'vVarView', class: 'lua-debug-server-row', style:"display:inline;", =>
      @div class: "server-con panel-body padded", click:'show_var_view', =>
        @div outlet:'var_icon', class: "block conf-heading icon icon-triangle-right", sViewName

      @div outlet:'var_list_panel', class: "server-con panel-body padded",style:"display:none;",  =>
        @div class:'control-ol', outlet:'locv_tree'

  initialize:(@sViewName) ->
    # console.log @locv_tree
    @iTestCon = 10


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

    # @test(@iTestCon)

  refresh_variable:(fFileName, oRe) ->

    # console.log fFileName, oRe
    # oRe = JSON.parse(sVariable)
    # console.log oRe
    # oRe = delete oRe.G
    if !@vVarEleView
      @vVarEleView = new VarEleView(oRe)
      @locv_tree.append @vVarEleView
    else
      @vVarEleView.refresh_variable(oRe)


  test:() ->
    @iTestCon = @iTestCon-1
    if @iTestCon is 9
      a='{"a":1123}'
      oRe = JSON.parse(a)
      console.log oRe
      @vVarEleView = new VarEleView(oRe)
      @locv_tree.append @vVarEleView
    else if @iTestCon is 8
      a='{ "b":2}'
      oRe = JSON.parse(a)
      console.log oRe
      @vVarEleView.refresh_variable(oRe)
    else if @iTestCon is 7
      a='{"b":3, "c":10000, "a": {"e":2,"f":1}}'
      oRe = JSON.parse(a)
      console.log oRe
      @vVarEleView.refresh_variable(oRe)
    else if @iTestCon is 6
      a='{"b":2, "c":10000, "a": {"e":3,"f":1}}'
      oRe = JSON.parse(a)
      console.log oRe
      @vVarEleView.refresh_variable(oRe)
    else if @iTestCon is 5
      a='{"a": {"e":2,"d":5}, "b":4, "c":10000}'
      oRe = JSON.parse(a)
      console.log oRe
      @vVarEleView.refresh_variable(oRe)
      @iTestCon = 10
    # a='{"a":1123,"c":10000,"b":2,"d": {"e":2,"f":1, "s":{"u":1, "p":3}},"ff":"<function >"}'
    # oRe = JSON.parse(a)
    # console.log oRe
    # for sKey, sVal of oRe
    # console.log @locv_tree1
    # vVarEleView = new VarEleView(oRe)
    # @locv_tree.append vVarEleView
    # vView = new TestV1(3)
