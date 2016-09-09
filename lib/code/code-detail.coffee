module.exports =
class CodeDetail
  sFileName:null
  sFilePath:null
  iLineNum:null
  sTextEditor:null
  shebang:null
  lang:null

  constructor:(@sTextEditor=null) ->
    @sFileName = @sTextEditor.getTitle()
    @sFilePath = @sTextEditor.getPath()
    @shebang = @getShebang()
    @lang = @getLang()

  getShebang: () ->
    sText = @sTextEditor.getText()
    aLines = sText.split("\n")
    sFirstLine = aLines[0]
    return unless sFirstLine.match(/^#!/)

    sFirstLine.replace(/^#!\s*/, '')

  getLang: () ->
    @sTextEditor.getGrammar().name
