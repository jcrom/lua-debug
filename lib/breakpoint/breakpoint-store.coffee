{CompositeDisposable, Emitter, Point} = require "atom"
_ = require 'underscore-plus'
path = require 'path'
LUA_BP_FLAG="emp_lua_dp_flag"

module.exports =
class BreakpointStore
  constructor:(@codeEventEmitter) ->
    console.log "BreakpointStore constructor"
    @oBPMaps = {}
    @oEditors = {}
    @markerMaps = {}
    @emitter = new Emitter()
    @codeEventEmitter.doBPEmit(@)

  addBreakpoint:(oBP, oEditor) ->
    # console.log oEditor
    # console.log breakpoint
    addDecoration = true
    # editor = atom.workspace.getActiveTextEditor()

    if @oBPMaps[oBP.sName]?[oBP.iLine]
      @refresh_flag(oEditor, -1)
      @deleteDP(oBP)
      addDecoration = false
    else
      # @oBPMaps[oBP.sID] = oBP
      @storeBP(oBP, oEditor)


    console.log "addDecorations:", addDecoration
    if addDecoration
      marker = oEditor.markBufferPosition([oBP.iLine-1, 0])
      d = oEditor.decorateMarker(marker, type: "line-number", class: "line-number-blue")
      d.setProperties(type: "line-number", class: "line-number-blue")
      oBP.decoration = d
      @addBPEmit(oBP)
    else
      # oEditor = atom.workspace.getActiveTextEditor()
      ds = oEditor.getLineNumberDecorations(type: "line-number", class: "line-number-blue")
      # console.log ds
      for d in ds
        marker = d.getMarker()
        marker.destroy() if marker.getBufferRange().start.row == oBP.iLine-1
      @delBPEmit(oBP)

  storeBP:(oBP, oEditor) ->
    # console.log "store bp:", oBP
    if !@oBPMaps[oBP.sName]
      @oBPMaps[oBP.sName] = {}
    @oBPMaps[oBP.sName][oBP.iLine] = oBP
    # TODO: 文件定位问题, 需要定向保存全路径
    @refresh_flag(oEditor, 1)
    @oEditors[oBP.sName] = oEditor

  deleteDP:(oBP) ->
    delete @oBPMaps[oBP.sName][oBP.iLine]

  refresh_flag:(oEditor, iAddInt) ->
    if iFlag = oEditor[LUA_BP_FLAG]
      oEditor[LUA_BP_FLAG] = iFlag+iAddInt
    else
      oEditor[LUA_BP_FLAG] = 1


  delBPCB:(oBP) ->
    # console.log oBP
    @deleteDP(oBP)
    oBP.decoration.getMarker().destroy()
    # @oBP.decoration.destroy()

  activeEditor:(sFileName, iLineNum) ->
    console.log sFileName, iLineNum
    oPoint = new Point(iLineNum-1, 0)
    sShortFileName = path.basename sFileName
    if !oEditor = @oEditors[sFileName]
      oEditor = @oEditors[sShortFileName]
    # oEditor?.setCursorScreenPosition(oPoint)
    if oEditor
      # console.log oEditor

      atom.workspace.open(oEditor.getPath(), { changeFocus:true }).then (oNewEditor) =>
        # console.log "after editor open", oNewEditor
        oNewEditor?.setCursorBufferPosition(oPoint)
        @oEditors[sShortFileName] = oNewEditor

        if oBPSubList = @oBPMaps[sShortFileName]
          # console.log "refresh bp ===========", oBPSubList
          if _.size(oBPSubList) > 0
            ds = oEditor.getLineNumberDecorations(type: "line-number", class: "line-number-blue")
            unless ds.length > 0
              for iK, oV of oBPSubList
                oV.decoration = @add_bp(oNewEditor, iK)
    else
      aEditorList = atom.workspace.getTextEditors()
      aFilterRe = _.filter aEditorList, (oTmpEditor) =>
        sTmpName = oTmpEditor.getTitle()
        sShortFileName is sTmpName

      # console.log aFilterRe
      if aFilterRe.length > 0
        console.log "has filtered editor"
        oTmpEditor = aFilterRe[0]
        atom.workspace.open(oTmpEditor.getPath(), { changeFocus:true }).then (oNewEditor) =>
          # console.log "after editor open", oNewEditor
          oNewEditor?.setCursorBufferPosition(oPoint)
          @oEditors[sShortFileName] = oNewEditor
      else
        console.log "no editor find"

      # _.each aEditorList, (oTmpEditor) =>
      #   sTmpName = oTmpEditor.getTitle()
      #   if sShortFileName is sTmpName
      #     atom.workspace.open(oTmpEditor.getPath(), { changeFocus:true }).then (oNewEditor) =>
      #       # console.log "after editor open", oNewEditor
      #       oNewEditor?.setCursorBufferPosition(oPoint)
      #       @oEditors[sShortFileName] = oNewEditor


    # console.log oNewEditor

  add_bp:(oEditor, iLine) ->

    marker = oEditor.markBufferPosition([iLine-1, 0])
    d = oEditor.decorateMarker(marker, type: "line-number", class: "line-number-blue")
    d.setProperties(type: "line-number", class: "line-number-blue")
    return d
    # oBP.decoration = d

    # if sFileName && iLineNum
    #   iLineNum = parseInt(iLineNum)
    #   options = {initialLine: iLineNum-1, initialColumn:0}
    #   atom.workspace.open(sFileName, options) #if fs.existsSync(fileName)

  addBPEmit:(bp) ->
    # console.log "add bp emit"
    @emitter.emit 'add-lua-bp', bp

  onAddBP:(callback) ->
    @emitter.on 'add-lua-bp', callback


  delBPEmit:(bp) ->
    @emitter.emit 'del-lua-bp', bp

  onDelBP:(callback) ->
    @emitter.on 'del-lua-bp', callback


  # addAllBPEmit:() ->
  #   # console.log "add bp emit"
  #   @emitter.emit 'add-all-bp', bp
  #
  # onAddAllBP:(callback) ->
  #   @emitter.on 'add-all-bp', callback
