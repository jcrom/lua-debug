# macro defined
fs = require 'fs'
path = require 'path'
os = require 'os'
remote = require 'remote'
dialog = remote.require 'dialog'

module.exports =
  LUA_GRAMMAR:'source.lua'

  # ----------------------------- Atom Config --------------------------------
  LUA_SERVER_HOST :'lua-debug.defLuaDebugServerHost'
  LUA_SERVER_PORT :'lua-debug.defLuaDebugServerPort'
  LUA_SERVER_TIMEOUT :'lua-debug.defLuaDebugServerTimeout'

  LUA_MSG_STEP:"STEP\n"
  LUA_MSG_RUN:"RUN\n"
  LUA_MSG_OVER:"OVER\n"
  LUA_MSG_OUT:"OUT\n"
  LUA_MSG_DONE:"DONE\n"

  # VIEW NAME
  LOCAL_VAR_VIEW_NAME:"Variables"
  UP_VAR_VIEW_NAME:"UP Variables"
  GLOBAL_VAR_VIEW_NAME:"Global Variables"


  get_pack_path: () ->
    atom.packages.resolvePackagePath(this.PACKAGE_NAME)

  get_temp_path: () ->
    atom.packages.resolvePackagePath(this.TEMP_PACKAGE_NAME)


  create_editor:(tmp_file_path, tmp_grammar, callback, content) ->
    changeFocus = true
    tmp_editor = atom.workspace.open(tmp_file_path, { changeFocus }).then (tmp_editor) =>
      gramers = @getGrammars()
      # console.log content
      unless content is undefined
        tmp_editor.setText(content) #unless !content
      tmp_editor.setGrammar(gramers[0]) unless gramers[0] is undefined
      callback(tmp_editor)

  # set the opened editor grammar, default is HTML
  getGrammars: (grammar_name)->
    grammars = atom.grammars.getGrammars().filter (grammar) ->
      (grammar isnt atom.grammars.nullGrammar) and
      grammar.name is 'CoffeeScript'
    grammars


  get_project_path: ->
    project_path_list = atom.project.getPaths()
    project_path = project_path_list[0]
    editor = atom.workspace.getActiveTextEditor()
    if editor
      # 判断 project 有多个的情况
      efile_path = editor.getPath?()
      if project_path_list.length > 1
        for tmp_path in project_path_list
          relate_path = path.relative tmp_path, efile_path
          if relate_path.match(/^\.\..*/ig) isnt null
            project_path = tmp_path
            break
    project_path

  toNumber:(tmpNum) ->
    tmpRe=parseInt(tmpNum)
    if isNaN(tmpRe)
      return 0
    else
      return tmpRe


module.exports.mk_rand = (iLen=6)->
  unless iLen <= 0
    iAtomP = Math.pow 10, iLen
    iRand = Math.round(Math.random()*iAtomP)
    if iRand > (iAtomP/10)
      return iRand
    else
      fix_rand(iRand, iAtomP)

fix_rand = (iRand, iAtomP) ->
  if iRand > (iAtomP/10)
    return iRand
  else
    fix_rand(iRand*10, iAtomP)


get_def_host = ->
  add_list = os.networkInterfaces()
  tmp_address = ''
  for key,val of add_list
    # console.log val
    for tmp_obj in val
      if !tmp_obj.internal and tmp_obj.family is 'IPv4'
        tmp_address = tmp_obj.address
        break

  tmp_address


module.exports.show_error = (err_msg) ->
  atom.confirm
    message:"Error"
    detailedMessage:err_msg
    buttons:["Ok"]

module.exports.show_warnning = (warn_msg) ->
  atom.confirm
    message:"Warnning"
    detailedMessage:warn_msg
    buttons:["Ok"]

module.exports.show_info = (info_msg) ->
  atom.confirm
    message:"Info"
    detailedMessage:info_msg
    buttons:["Ok"]

module.exports.self_info = (title_msg, detail_msg) ->
  atom.confirm
    message:title_msg
    detailedMessage:detail_msg
    buttons:["Ok"]


module.exports.isEmpty = (obj) ->
    for key,name of obj
        false;
    true;

module.exports.get_emp_os = () ->
  tmp_os = os.platform().toLowerCase()
  if atom.project
    if !atom.project.emp_os
      atom.project.emp_os = tmp_os
    atom.project.emp_os
  else
    tmp_os


module.exports.mkdir_sync = (tmp_dir) ->
  if !fs.existsSync(tmp_dir)
    fs.mkdirSync(tmp_dir);

module.exports.mkdirs_sync = (root_dir, dir_list) ->
  for dir in dir_list
    tmp_dir = root_dir+dir
    if !fs.existsSync(tmp_dir)
      fs.mkdirSync(tmp_dir);

module.exports.mkdir_sync_safe = (tmp_dir) ->
   if !fs.existsSync(tmp_dir)
     this.mkdir_sync_safe(path.dirname tmp_dir)
     fs.mkdirSync(tmp_dir);

module.exports.base64_encode = (data) ->
  new Buffer(data).toString('base64')

module.exports.base64_decode = (data) ->
  new Buffer(data, 'base64').toString()

mk_dirs_sync = (p, made) ->
  # default mode is 0777

  # mask = ~process.umask()
  #
  # mode = 0777 & (~process.umask()) unless mode
  made = null unless made
  # mode = parseInt(mode, 8) unless typeof mode isnt 'string'
  p = path.resolve(p)
  try
      fs.mkdirSync(p)
      made = made || p
  catch err0
    switch err0.code
        when 'ENOENT'
          made = mk_dirs_sync(path.dirname(p), made)
          mk_dirs_sync(p, made)

        # // In the case of any other error, just see if there's a dir
        # // there already.  If so, then hooray!  If not, then something
        # // is borked.
        else
          stat = null
          try
              stat = fs.statSync(p)
          catch err1
              throw err0
          unless stat.isDirectory()
            throw err0
  made

# 选择路径
module.exports.chose_path_f = (def_path='', callback)->
  @chose_path(['openFile'], def_path, callback)

module.exports.chose_path_d = (callback)->
  @chose_path(['openFile', 'openDirectory'], '', callback)

module.exports.chose_path = (opts=['openFile', "openDirectory"], def_path, callback)->
  dialog.showOpenDialog title: 'Select', defaultPath:def_path, properties: opts, (cho_path) =>
    if cho_path
      if callback
        callback(cho_path[0])

valid_ip = (ip_add)->
    # console.log ip_add
    ip_add.match(///^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$///ig)

module.exports.mk_dirs_sync = mk_dirs_sync
module.exports.valid_ip = valid_ip
