path = require 'path'
module.exports =
class Breakpoint
  decoration: null
  constructor:(@sName, @sFile, @iLine) ->
    @sBaseName = @sName
    sDirNameOne = path.dirname @sFile
    sBaseDirOne = path.basename(sDirNameOne).toLowerCase()
    sDirNameTwo = path.dirname sDirNameOne
    sBaseDirTwo = path.basename(sDirNameTwo).toLowerCase()

    if (sBaseDirOne is "lua") and (sBaseDirTwo isnt "common")
      @sName = path.join sBaseDirTwo, sBaseDirOne, @sBaseName


    @sID = "#{@sName}:#{@iLine}"

  addCommand: ->
    "SETB #{@sName} #{@iLine}\n"

  delCommand: ->
    "DELB #{@sName} #{@iLine}\n"
