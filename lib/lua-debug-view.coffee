{CompositeDisposable, Emitter} = require 'atom'
{$, $$, View,TextEditorView} = require 'atom-space-pen-views'
DebugSocket = require './net/debug-server'
BPEleView = require './bp-ele-view'
LuaDebugVarView = require './variable/lua-variable-view'
# LuaDebugGloVarView = require './variable/lua-global-variable-view'
# LuaDebugUPVarView = require './variable/lua-up-variable-view'

# CodeRunner = require './code/code-runner'
# CodeView = require './code/code-view'

emp = require './global/emp'

module.exports = class LuaDebugView extends View
  modalPanel:null
  aBPMap:null
  # oDebugServer:null
  # codeView:null


  @content: ->
    @div class: 'lua-debug-view tool-panel',=>
      @div  class:'lua-debug-panel', =>
        @div outlet:'vLuaDebugFlow', class:'lua-debug-flow',  =>

          @div outlet: 'vServerConfView', class: 'lua-debug-server-row',style:"display:node;", =>
            @div class: "server-con panel-body padded", =>
              @div class: "block conf-heading icon icon-gear", "Lua Debug Server"
            @div class: "server-con panel-body padded", =>
              @label class: "debug-label", "Host "
              @div class: 'controls', =>
                @div class: 'setting-editor-container', =>
                  @subview 'vHostTextEditor', new TextEditorView(mini: true, attributes: {id: 'emp_host', type: 'string'}, placeholderText: 'Server Host')
              @label class: "debug-label", "Port "
              @div class: 'controls', =>
                @div class: 'setting-editor-container', =>
                  @subview 'vPortTextEditor', new TextEditorView(mini: true, attributes: {id: 'emp_port', type: 'string'}, placeholderText: 'Server Port')
              @button class: 'btn btn-else btn-primary inline-block-tight ', click: 'start_server', "Start Server"

          # server state inline
          @div outlet: 'vServerStateView', class: 'lua-debug-server-row', style:"display:none;", =>
          # @div outlet: 'vServerStateView', class: 'lua-debug-server-row', style:"display:inline;", =>
            @div class: "server-con panel-body padded", =>
              @div class: "block conf-heading icon icon-gear", "Lua Debug Server"

            @div class: "server-con panel-body padded",  =>
              @div class: "state-div-content", =>
                @label class: "debug-label", "Server State   : "
                @label outlet:"vServerState", class: "debug-label-content", "--"
              @div class: 'controls', =>
                @div class: 'setting-editor-container', =>
                  @subview 'vMsgEditor', new TextEditorView(mini: true, attributes: {id: 'msg', type: 'string'}, placeholderText: 'Send Msg')
              # @div class: "state-div-content", =>
              #   @label class: "debug-label", "Client Number: "
              #   @label outlet:"emp_cl_no", class: "debug-label-content", ""
              @button class: 'btn btn-else btn-error inline-block-tight', click: 'stop_server', "Stop Server"
              @button class: 'btn btn-else btn-info inline-block-tight', click: 'send_msg', "Send"
            @div class: "server-con panel-body padded",  =>
              @button class: 'btn btn-else btn-primary inline-block-tight ', click: 'run_code', "Run Code In Atom"
            @div class: "server-con panel-body padded",  =>
              @div class: "control-btn-group btn-group" ,=>
                @button class: 'btn icon icon-playback-play btn-else', title:"Run Until Next Breakpoint" ,click: 'send_run'
                @button class: 'btn icon icon-move-down btn-else', title:"Step Over" ,click: 'send_over'
                @button class: 'btn icon icon-steps btn-else', title:"Step Into" ,click: 'send_step'
                @button class: 'btn icon icon-move-up btn-else', title:"Step Out" ,click: 'send_out'
                @button class: 'btn icon icon-arrow-down btn-else', title:"Run Done" ,click: 'send_done'


          # break points list
          @div outlet: 'vBPView', class: 'lua-debug-server-row', style:"display:inline;", =>
            @div class: "server-con panel-body padded", =>
              @div class: "block conf-heading icon icon-gear", "BreakPoints"

            @div class: "server-con panel-body padded",  =>
              # @div class: "state-div-content", =>
              #   @label outlet:"vServerState", class: "debug-label-content", "--"
              @div class:'control-ol', =>
                @table class:'control-tab',outlet:'bp_tree'

          # # local variable list
          # @div outlet: 'vVarView', class: 'lua-debug-server-row', style:"display:inline;", =>
          #   @div class: "server-con panel-body padded", =>
          #     @div class: "block conf-heading icon icon-gear", "Variables"
          #
          #   @div class: "server-con panel-body padded",  =>
          #     # @div class: "state-div-content", =>
          #     #   @label outlet:"vServerState", class: "debug-label-content", "--"
          #     @div class:'control-ol', =>
          #       @table class:'control-tab',outlet:'glv_tree'

  initialize:(serializeState, @codeEventEmitter) ->
    @aBPMap = {}
    @emitter = new Emitter
    # @oDebugServer = new DebugSocket()
    @disposable = new CompositeDisposable
    # @codeView = new CodeView()
    @codeEventEmitter.doManaEmit(@)
    @luaDebugVarView = new LuaDebugVarView(emp.LOCAL_VAR_VIEW_NAME)
    @luaDebugUPVarView = new LuaDebugVarView(emp.UP_VAR_VIEW_NAME)
    @luaDebugGloVarView = new LuaDebugVarView(emp.GLOBAL_VAR_VIEW_NAME )

    @disposable.add atom.commands.add "atom-workspace","lua-debug:toggle", => @toggle_show()
    @disposable.add @luaDebugVarView,@luaDebugUPVarView, @luaDebugGloVarView
    # @disposable.add @oDebugServer
    @vLuaDebugFlow.append @luaDebugVarView
    @vLuaDebugFlow.append @luaDebugUPVarView
    @vLuaDebugFlow.append @luaDebugGloVarView

    @sServerHost = atom.config.get(emp.LUA_SERVER_HOST)
    @sServerPort = atom.config.get(emp.LUA_SERVER_PORT)
    @vHostTextEditor.setText @sServerHost
    @vPortTextEditor.setText @sServerPort

    # initial listening
    @vHostTextEditor.getModel().onDidStopChanging =>
      sNewServerHost = @vHostTextEditor.getText().trim()
      atom.config.set(emp.LUA_SERVER_HOST, sNewServerHost)

    @vPortTextEditor.getModel().onDidStopChanging =>
      sNewServerPort = @vPortTextEditor.getText().trim()
      atom.config.set(emp.LUA_SERVER_PORT, sNewServerPort)



  toggle_show:() ->
    unless @modalPanel
      @modalPanel = atom.workspace.addRightPanel(item:this,visible:true)
      return

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()


  # Returns an object that can be retrieved when package is activated
  serialize: ->
    # @vLuaDebugFlow.append @luaDebugVarView


  # Tear down any state and detach
  destroy: ->
    @dispose()

  dispose:()->
    @aBPMap = {}
    @modalPanel.destroy()
    @disposable?.dispose()

  # hanle click callback
  start_server: (event, element) =>

    sNewServerHost = @sServerHost unless sNewServerHost = @vHostTextEditor.getText().trim()
    sNewServerPort = @sServerPort unless sNewServerPort = @vPortTextEditor.getText().trim()
    console.log sNewServerHost,sNewServerPort
    @emitter.emit 'start_server', {host:sNewServerHost, port:sNewServerPort}
    #
    # @oDebugServer.start(sNewServerHost,sNewServerPort, @show_state_panel, @show_server_panel)
    # @show_state_panel()

  send_msg:(event, element) ->
    sMsg = @vMsgEditor.getText()
    console.log sMsg
    if sMsg
      @emitter.emit 'send_msg', sMsg

  onSendMsg:(callback)->
    @emitter.on 'send_msg', callback


  stop_server:(event, element) ->
    @emitter.emit 'stop_server'
    # @oDebugServer.close()
    # @show_server_panel()

  # some callback
  show_server_panel:() =>
    @vServerConfView.show()
    @vServerStateView.hide()

  show_state_panel:() =>
    @vServerState["context"].innerHTML = "On"

    @vServerConfView.hide()
    @vServerStateView.show()

  refresh_variable:(fFileName, sVariable) =>
    # console.log "show variable:+++++++", fFileName, sVariable
    if typeof(sVariable) is 'string'
      oRe = JSON.parse(sVariable)
    else
      oRe = sVariable
    @luaDebugVarView.refresh_variable(fFileName, oRe.locVal)
    @luaDebugUPVarView.refresh_variable(fFileName, oRe.upVal)
    @luaDebugGloVarView.refresh_variable(fFileName, oRe.G)


  addBPCB:(bp) ->
    # console.log bp
    vBPEleView = new BPEleView(@delBPEvnent, bp)
    @aBPMap[bp.sID] = vBPEleView
    @bp_tree.append vBPEleView

  delBPCB:(bp) ->
    if vBPEleView = @aBPMap[bp.sID]
      vBPEleView.destroy()

  # event emit

  delBPEvnent:(bp) =>
    @emitter.emit 'del_bp', bp

  run_code:() =>
    @emitter.emit 'start'

  stop_run:() =>
    @emitter.emit 'stop'



  # send msg to socket
  # runs until next breakpoint
  send_run:() =>
    @emitter.emit 'send_run'

  # runs until next line, stepping over function calls
  send_over:() =>
    @emitter.emit 'send_over'

  # runs until next line, stepping into function calls
  send_step:() =>
    @emitter.emit 'send_step'
    # @oDebugServer.send(emp.LUA_MSG_STEP)

  # runs until line after returning from current function
  send_out:() =>
    @emitter.emit 'send_out'
    # @oDebugServer.send(emp.LUA_MSG_OVER)

  send_done:() =>
    @emitter.emit 'send_done'
    # @oDebugServer.send(emp.LUA_MSG_DONE)


  onSendRun:(callback)->
    @emitter.on 'send_run', callback
  onSendOver:(callback)->
    @emitter.on 'send_over', callback
  onSendStep:(callback)->
    @emitter.on 'send_step', callback
  onSendOut:(callback)->
    @emitter.on 'send_out', callback
  onSendDone:(callback)->
    @emitter.on 'send_done', callback

  # -------

  # onLogStdOut: (callback) ->
  #   @oCodeRunner.onLogStdOut callback
  #
  # onLogStdErr: (callback) ->
  #   @oCodeRunner.onLogStdErr callback
  #
  # onLogExit: (callback) ->
  #   @oCodeRunner.onLogExit callback
  #
  # onDidNotRun: (callback) ->
  #   @oCodeRunner.onDidNotRun callback

  onStartServer:(callback) ->
    @emitter.on 'start_server', callback

  onStopServer:(callback) ->
    @emitter.on 'stop_server', callback

  onStart: (callback) ->
    @emitter.on 'start', callback

  onStop: (callback) ->
    @emitter.on 'stop', callback

  onDelBPEvnent:(callback) ->
    @emitter.on 'del_bp', callback
