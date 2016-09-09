{CompositeDisposable} = require 'atom'
LuaDebugView = require './lua-debug-view'
LuaEditor = require './lua-editor'
CodeRunner = require './code/code-runner'
CodeEventEmitter = require './event-emitter'
CodeView = require './code/code-view'
DebugSocket = require './net/debug-server'
BreakpointStore = require './breakpoint/breakpoint-store'

module.exports =

  config:
    defLuaDebugServerHost:
      type:'string'
      default:'default'

    defLuaDebugServerPort:
      type:'string'
      default:'8172'

    defLuaDebugServerTimeout:
      type:'integer'
      default:'14400000'


  luaDebugView:null
  codeEventEmitter:null
  oCodeRunner:null
  oDebugServer:null
  luaEditor:null
  oBreakpointStore:null


  activate:(state) ->

    @luaEditor = new LuaEditor()


    @oDebugServer = new DebugSocket()
    @codeView = new CodeView()
    @codeEventEmitter = new CodeEventEmitter(@codeView, @oDebugServer)
    @oCodeRunner = new CodeRunner(@codeEventEmitter)
    @luaDebugView = new LuaDebugView(state, @codeEventEmitter)
    @oBreakpointStore = new BreakpointStore(@codeEventEmitter)
    @luaEditor.init(@oBreakpointStore)




  deactivate: ->
    # subscriptions.dispose();
    # subscriptions = null
    @oBreakpointStore.dispose()
    @oDebugServer.dispose()
    @codeEventEmitter.dispose()
    @oCodeRunner.dispose()
    @luaDebugView.dispose()

  serialize: ->
    luaDebugView:@luaDebugView.serialize()



#
# export default {
#
#   activate(state) {
#     console.log("active");
#     // luaDebugView = new LuaDebugView(state.luaDebugViewState);
#     panel = require('./component/panel.jsx');
#     panel.init()
#     console.log("require panel");
#
#     // this.modalPanel = atom.workspace.addModalPanel({
#     //   item: this.luaDebugView.getElement(),
#     //   visible: false
#     // });
#
#     // // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
#     subscriptions = new CompositeDisposable(
#       atom.commands.add('atom-workspace',{
#         'lua-debug:toggle': () => panel.toggle()
#       }),
#       panel
#     );
#     //
#     // // Register command that toggles this view
#     // this.subscriptions.add(atom.commands.add('atom-workspace', {
#     //   'lua-debug:toggle': () => this.toggle()
#     // }));
#   },
