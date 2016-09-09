CodeDetail = require './code-detail'
{Emitter, BufferedProcess} = require 'atom'

path = require 'path'
fs = require 'fs'

sCmd = 'lua'

module.exports =
class CodeRunner
  constructor:(@codeEventEmitter) ->
    console.log 'code builder constructor'
    @emitter = new Emitter()
    @codeEventEmitter.doCodeEmit(@)

  dispose: ->
    @emitter.dispose()

  run_code: ->
    oCodeDetail = @buildCode()
    command = sCmd
    options = @options()
    stdout = @stdoutFun
    stderr = @stderrFun
    exit = @exitFun

    args = [oCodeDetail.sFilePath]
    # console.log command, args, options
    @bufferedProcess = new BufferedProcess({
      command, args, options, stdout, stderr, exit
    })

    @bufferedProcess.onWillThrowError(@createOnErrorFunc(command))

  stdoutFun:(output) =>
    console.log output
    @emitter.emit 'did-log-stdout', { type:'stdout', msg: output }

  onLogStdOut: (callback)->
    @emitter.on 'did-log-stdout', callback

  stderrFun:(output) =>
    console.error output
    @emitter.emit 'did-log-stderr', { type:'stderr', msg: output }

  onLogStdErr: (callback)->
    @emitter.on 'did-log-stderr', callback

  exitFun:(reCode) =>
    console.log reCode
    @bufferedProcess = null
    @emitter.emit 'did-log-exit', { reCode: reCode }

  onLogExit: (callback) ->
    @emitter.on 'did-log-exit', callback

  createOnErrorFunc: (command) =>
    (nodeError) =>
      @bufferedProcess = null
      @emitter.emit 'did-not-run', { command: command }
      nodeError.handle()

  onDidNotRun: (callback) ->
    @emitter.on 'did-not-run', callback




  stop: ->
    unless !@bufferedProcess
      @bufferedProcess.kill()
      @bufferedProcess = null

  buildCode:() ->
    eTmpEditor = atom.workspace.getActiveTextEditor()
    # eTmpEditor.save()

    oSelection = eTmpEditor.getLastSelection()
    oCodeDetail = new CodeDetail(eTmpEditor)
    # console.log oCodeDetail
    return oCodeDetail

  options: ->
    cwd: @getCwd()
    env: process.env

  getCwd: ->
    paths = atom.project.getPaths()
    # console.log paths
    cwd = null
    if paths?.length > 0
      try
        cwd = if fs.statSync(paths[0]).isDirectory() then paths[0] else path.join(paths[0], '..')

    cwd
