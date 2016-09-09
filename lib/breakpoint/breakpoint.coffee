module.exports =
class Breakpoint
  decoration: null
  constructor:(@sName, @sFile, @iLine) ->
    @sID = "#{@sName}:#{@iLine}"

  addCommand: ->
    "SETB #{@sName} #{@iLine}\n"

  delCommand: ->
    "delb #{@sName} #{@iLine}\n"
