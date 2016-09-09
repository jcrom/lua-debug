{CompositeDisposable, Emitter} = require 'atom'
{$, $$, View, TextEditorView} = require 'atom-space-pen-views'

_ = require 'underscore-plus'


module.exports =
class CodeView extends View
  codePanel:null

  @content:->
    @div class: 'code-view tool-panel pannel panel-bottom native-key-bindings', =>
      @div class:'resize-div', mousedown: 'resizeStarted', dblclick: 'resizeToMin'
      @div class: 'panel-heading',=>
        @div class: 'heading-title inline-block', =>
          @div class:'header-view', =>
            @span class:'heading-title', "Lua Code Runner"
        @div class: 'heading-summary inline-block'
        @div class:'heading-buttoms inline-block pull-right', =>
          @div class:'heading-close inline-block icon-x', click:'hide'

      @div outlet:'log_body', class:'code-body panel-body padded'

  initialize:(serializeState) ->
    console.log "code view constructor ---- "

  destroy: ->
    @dispose()

  dispose:()->
    @codePanel.destroy()


  toggle: ->
    unless @codePanel
      @codePanel = atom.workspace.addBottomPanel(item:this,visible:true)
      return

    if !@codePanel.isVisible()
      #   @codePanel.hide()
      # else
      @codePanel.show()

  hide: ->
    @codePanel.hide()


  showMsg:(sType, sMsg)->
    console.log sType, sMsg
    # if msg?.type is 'stdout'
    @log_body.append $$ ->
      @pre class: "line #{sType}", =>
        @raw sMsg
    @log_body.scrollToBottom()

  setOver: (msg)->
    console.info "Run Over:", msg.reCode


  resizeStarted: ->
    $(document).on('mousemove', @resizeBodyView)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: ->
    $(document).off('mousemove', @resizeBodyView)
    $(document).off('mouseup', @resizeStopped)

  resizeBodyView: (e) =>
    {pageY, which} = e
    return @resizeStopped() unless which is 1
    height = $(document.body).height()-pageY

    return if height < 30
    @height(height)
    @log_body.css("max-height", height)

  resizeToMin: ->
    height = 30
    @height(height)
    @log_body.css("max-height", height)
    @log_body.scrollToBottom()
