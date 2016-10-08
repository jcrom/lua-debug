{CompositeDisposable, Emitter, Point} = require "atom"
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
    console.log oEditor
    # console.log breakpoint
    addDecoration = true
    # editor = atom.workspace.getActiveTextEditor()

    if @oBPMaps[oBP.sID]
      delete @oBPMaps[oBP.sID]
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
      for d in ds
        marker = d.getMarker()
        marker.destroy() if marker.getBufferRange().start.row == oBP.iLine-1
      @delBPEmit(oBP)

  storeBP:(oBP, oEditor) ->
    @oBPMaps[oBP.sID] = oBP
    # TODO: 文件定位问题, 需要定向保存全路径
    @oEditors[oBP.sName] = oEditor




  delBPCB:(oBP) ->
    # console.log oBP
    delete @oBPMaps[oBP.sID]
    oBP.decoration.getMarker().destroy()
    # @oBP.decoration.destroy()

  activeEditor:(sFileName, iLineNum) ->
    console.log sFileName, iLineNum
    oPoint = new Point(iLineNum-1, 0)
    oEditor = @oEditors[sFileName]
    # oEditor?.setCursorScreenPosition(oPoint)
    oEditor?.setCursorBufferPosition(oPoint)
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
