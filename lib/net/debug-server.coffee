{CompositeDisposable, Emitter} = require 'atom'

net = require('net');
_ = require('underscore-plus')
emp = require '../global/emp'
DEFAULT_HOST = 'default'
DEFAULT_PORT = '8172'
DEFAULT_TIMEOUT = 14400000

module.exports = class DebugSocket
  oServer:null
  bServerState:false
  aSocketArr:{}
  # fSCallback:null
  # fFCallback:null

  constructor:() ->
    console.log "----constructor---"
    @emitter = new Emitter()


  initial:(oSocket) =>
    # iRemotePort = oSocket.remotePort
    iPort = oSocket.remotePort
    sRemoteAddress = oSocket.remoteAddress
    console.log "New Client connect:#{sRemoteAddress}:#{iPort}"
    oSocket.on 'data', (oData)=>
      console.log "data:#{oData}"
      # console.log typeof oData
      # console.log oData
      sData = oData.toString()
      # console.log oData[oData.length-1]
      # console.log oData[oData.length-1] is '\0'
      # tailFlag = 0  #字符串结尾再减一
      # tailChar = sData.substr -1, 1 # 取得data最后一个字符
      # console.log tailChar
      # if tailChar == '\0'
      #   tailFlag = 1
      #   console.log "tailChar is \\0 "

      newDataArr = sData.split /\n/ig
      console.log newDataArr
      _.each newDataArr, (newData) =>
        # console.log newData
        sState = newData.match(/^(\d)+/ig)?[0]
        switch sState
          when '202'
            console.log newData
            aNewArr = newData.match /^202 Paused\s+(\S+)\s(\d*)\s(.*)?/
            console.log aNewArr
            sFileName = aNewArr[1]
            iLineNum = emp.toNumber aNewArr[2]
            sLocalVar = aNewArr[3]
            console.log sFileName, iLineNum, sLocalVar
            @emitRTInfo(sFileName, iLineNum, sLocalVar)

          else
            console.log "state:#{sState}"


    oSocket.on 'close', (data)=>
      console.log "Client close:#{sRemoteAddress}"
      @delSocket(iPort)

    oSocket.setTimeout DEFAULT_TIMEOUT, =>
      console.log("Client connect timeout")
      oSocket.end()

  # start server
  start:(iIP=DEFAULT_HOST, iPort=DEFAULT_PORT, @fSCallback, @fFCallback)=>
    console.log "Start debug server!:#{iIP}:#{iPort}"

    @oServer = net.createServer @initial
    @oServer.on 'error', (exception) =>
      if exception.code is 'EADDRINUSE'
        console.error('Address in use, retrying...');
        @oServer = null
        # @fFCallback() unless !@fFCallback
        @closed()
        # emp_server_error = 'EADDRINUSE'
        emp.show_error("Address or Port in use, retrying...")
      else
        console.error "socket start error"
        console.error exception

    if iIP is DEFAULT_HOST
      @oServer.listen(iPort)
    else
      @oServer.listen(iPort, iIP)

    @oServer.on 'connection', (oSocket) =>
      console.log "new client in +++++++ "
      iRPort = @store(oSocket)
      @getAllBP(iRPort)

    @oServer.on 'listening', =>
      console.log '\nSocket Server start as:' + @oServer.address().address + ":" +@oServer.address().port

    # @fSCallback() unless !@fSCallback
    @started()

  # close serverstart server
  dispose: ->
    @close()

  close: () ->
    console.log "Cllose Debug server"
    try
      if @oServer
        @oServer.close()
        @resetState()
        console.log "close socket sever over"
      else
        console.log "close socket sever over"
      # @fFCallback() unless !@fFCallback
      @closed()
    catch exc
      @resetState()

  store:(oSocket)=>
    iRPort = oSocket.remotePort
    @aSocketArr[iRPort] = oSocket
    return iRPort

  delSocket:(iPort)=>
    delete @aSocketArr[iPort]


  send:(sMsg)->
    for k, oSocket of @aSocketArr
      # _.each @aSocketArr, (oSocket)=>
      oSocket.write(sMsg)

  send_specify:(oSocket, sMsg)->
    oSocket.write(sMsg)

  addBPCB:(bp) ->
    console.log "send :add"
    @send(bp.addCommand())


  delBPCB:(bp) ->
    console.log "send :del"
    @send(bp.delCommand())

  sendAllBPsCB:({msg:iRPort}, oBPMaps) ->
    if oSocket = @aSocketArr[iRPort]
      for k, aBPList of oBPMaps
        for iL, oBP of aBPList
          @send_specify(oSocket, oBP.addCommand())



  resetState:() ->
    @bServerState = false
    @oServer = null
    @aSocketArr = {}
    # @fSCallback = null
    # @fFCallback = null

  # handle emitter
  started:() =>
    @emitter.emit 'started'

  onStarted:(callback) ->
    @emitter.on 'started', callback

  closed:()=>
    @emitter.emit 'closed'

  onClosed:(callback) ->
    @emitter.on 'closed', callback

  getAllBP:(iRPort) =>
    @emitter.emit 'get-all-bp',{msg:iRPort}

  onGetAllBP:(callback) ->
    @emitter.on 'get-all-bp', callback

  # 发送 client 端的状态给 editor, 并使该 editor 被选中
  emitRTInfo:(sFileName, iLineNum, sLocalVar) =>
    @emitter.emit 'get-runtime-info', {name:sFileName, line:iLineNum, variable:sLocalVar}

  onRTInfo:(callback) ->
    @emitter.on 'get-runtime-info', callback
