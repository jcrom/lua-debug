{View} = require 'atom-space-pen-views'

module.exports =
class BPEleView extends View

  @content: (cb, oBreakpoint) ->
    @tr =>
      @td =>
        @span outlet: 'ele_name', class: 'text-info status-added icon icon-diff-added', oBreakpoint.sID
      @td class:'btn-td ', align:"right", =>
        @div class:'db-remove inline-block icon status-removed icon-diff-removed', click:'del_dp'

        # @button class:'btn btn-info',click:'do_edit',"Edit"
        # @button class:'btn btn-error',click:'do_remove',"Remove"


  initialize: (@callback, @oBreakpoint) ->


  destroy: ->
    @detach()

  del_dp: ->
    @callback(@oBreakpoint)
    @detach()
