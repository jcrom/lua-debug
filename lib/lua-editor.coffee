{CompositeDisposable} = require 'atom'
emp = require './global/emp'
Breakpoint = require './breakpoint/breakpoint'

module.exports =
class LuaEditor
  breakMarkers:null
  editorMap:null

  constructor:() ->
    # console.log "lua editor constructor"
    @disposable = new CompositeDisposable()
    @breakMarkers = []
    @editorMap = new Map()

  init:(@oBreakpointStore) =>
    @disposable.add atom.workspace.observeTextEditors(@observeTextEditors)

  observeTextEditors:(tmpEditor) =>
    grammar = tmpEditor.getGrammar()
    unless grammar.scopeName is emp.LUA_GRAMMAR
      return
    # console.log grammar

    # o = {markers:[],gutter: tmpEditor.addGutter({ name: 'lua-debug', priority: -100 })
    # }

    tmpGutter = tmpEditor.addGutter({ name: 'lua-debug', priority: -100 })

    gutterView = atom.views.getView(tmpGutter)
    gutterView.addEventListener 'click', (ev)=> @onGutterClick(tmpEditor, ev)

  onGutterClick:(editor, ev) =>
    # console.log "onGutterClick callback"
    editorView = atom.views.getView editor
    {row:sLine} = editorView.component.screenPositionForMouseEvent(ev)
    sNLine = editor.bufferRowForScreenRow(sLine)+1
    sName = editor.getTitle()
    sFile = editor.getPath()

    @addBreakpoint(sName, sFile, sNLine, editor)

  addBreakpoint:(sName, sFile, sLine, oEditor) =>
    # console.log 'addBreakpoint'
    oBP = new Breakpoint(sName, sFile, sLine)
    @oBreakpointStore.addBreakpoint(oBP, oEditor)

  dispose: ->
    @disposable.dispose()
