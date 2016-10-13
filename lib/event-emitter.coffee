{CompositeDisposable} = require 'atom'
emp = require './global/emp'

module.exports =
class CodeEventEmitter

  constructor:(@codeView, @oDebugServer) ->
    @disposable = new CompositeDisposable

  doCodeEmit:(@CodeRunner) ->

    @disposable.add @CodeRunner.onLogStdOut (e)=>
      @codeView.showMsg e.type, e.msg

    @disposable.add @CodeRunner.onLogStdErr (e)=>
      @codeView.showMsg e.type, e.msg

    @disposable.add @CodeRunner.onLogExit (e)=>
      @codeView.setOver e


  doManaEmit:(@luaDebugView) ->
    @disposable.add @luaDebugView.onStart (e)=>
      # @codeView.show e
      @codeView.toggle()
      @CodeRunner.run_code()

    @disposable.add @luaDebugView.onStop (e)=>
      @codeView.toggle()

    #socket server
    @disposable.add @luaDebugView.onStartServer (e)=>
      @oDebugServer.start e.host, e.port

    @disposable.add @luaDebugView.onStopServer (e)=>
      @oDebugServer.close()


    @disposable.add @luaDebugView.onSendRun (e)=>
      @oDebugServer.send(emp.LUA_MSG_RUN)

    @disposable.add @luaDebugView.onSendStep (e)=>
      @oDebugServer.send(emp.LUA_MSG_STEP)

    @disposable.add @luaDebugView.onSendOver (e)=>
      @oDebugServer.send(emp.LUA_MSG_OVER)

    @disposable.add @luaDebugView.onSendDone (e)=>
      @oDebugServer.send(emp.LUA_MSG_DONE)

    @disposable.add @luaDebugView.onSendOut (e)=>
      @oDebugServer.send(emp.LUA_MSG_OUT)

    # use for test
    @disposable.add @luaDebugView.onSendMsg (sMsg)=>
      @oDebugServer.send(sMsg)

    @disposable.add @luaDebugView.onDelBPEvnent (bp)=>
      @oBreakpointStore.delBPCB(bp)
      @oDebugServer.delBPCB bp
      # @oDebugServer.send(emp.LUA_MSG_DONE)


    # @disposable.add @luaDebugView.onSendDone (e)=>
      # @oDebugServer.send(emp.LUA_MSG_DONE)

    @disposable.add @oDebugServer.onStarted (e)=>
      @luaDebugView.show_state_panel()
    @disposable.add @oDebugServer.onClosed (e)=>
      @luaDebugView.show_server_panel()
    @disposable.add @oDebugServer.onGetAllBP (e)=>
      @oDebugServer.sendAllBPsCB(e, @oBreakpointStore.oBPMaps)
    @disposable.add @oDebugServer.onRTInfo (e) =>
      @oBreakpointStore.activeEditor(e.name, e.line)
      @luaDebugView.refresh_variable(e.name, e.variable)




  doBPEmit:(@oBreakpointStore) ->
    @disposable.add @oBreakpointStore.onAddBP (bp)=>
      @luaDebugView.addBPCB bp
      @oDebugServer.addBPCB bp

    @disposable.add @oBreakpointStore.onDelBP (bp)=>
      @luaDebugView.delBPCB bp
      @oDebugServer.delBPCB bp

  destroy: ->
    @dispose()

  dispose:->
    @disposable.dispose()
