Core = require './core'
{ extname, join, isAbsolute, normalize } = require 'path'
{ FindType } = require './util'
replacer = require './replacer'
{ _extend } = require 'util'

class OnParser # Object notation parser, type agnostic

  onDownload: (fn) -> @_onDownload = fn; @

  onExtract: (fn) -> @_onExtract = fn; @

  parse: (obj) ->
    if typeof obj != 'object'
      throw new Error('You need to provide an object or an array')

    @_obj = obj
    @_parse()
    @

  _parse: (obj, extend) ->
    obj ?= @_obj
    obj = if Array.isArray(obj) then obj else [ obj ]
    @_iterate(obj, extend)

  _iterate: (obj, extend) ->
    obj.forEach (i) =>
      i = _extend i, extend
      @_iterateItem i

  _iterateItem: (item) ->
    url = item.url
    find = item.find
    findIndex = item.findIndex ? 0
    findType = FindType[item.findType ? 'cheerio']
    attr = item.attr ? 'href'
    useText = item.text ? false
    thenObj = item.then ? false
    filename = item.filename ? false
    filenameMode = item.filenameMode ? ['urlBasename', 'contentType']
    directory = item.directory ? ''
    execute = item.execute ? false
    extract = item.extract ? false

    containerPromise = Core.page(url).find(find)

    containerPromise.then (containerInstance) =>
      if findIndex != 0
        containerInstance = containerInstance.index(findIndex)

      if useText == true
        attrInstance = containerInstance.text()
      else
        attrInstance = containerInstance.attr(attr)

      if thenObj != false
        extend = { url: attrInstance.value() }
        return @_parse(thenObj, extend)

      downloadOptions = {}
      downloadOptions.filenameMode = filenameMode
      downloadOptions.directory = replacer.replace(directory)

      [].concat(filenameMode).forEach (i) ->
        downloadOptions.filenameMode[i] = true

      if typeof filename == 'string'
        downloadOptions.filenameMode['predefined'] = filename

      fileInstance = attrInstance.download(downloadOptions, @_onDownload)

      if execute != false
        fileInstance.execute(execute)

      if extract != false
        if extract.to?
          extract.to = replacer.replace(extract.to)
        fileInstance.extract(extract, @_onExtract)

class Parser extends OnParser
  _getObj: (filepath) ->
    if typeof filepath == 'object'
      obj = filepath
    else
      realfilepath = if isAbsolute(filepath) then filepath else join(process.cwd(), filepath)
      ext = extname(filepath)
      if ext == '.json'
        obj = require(realfilepath)
      else if ext == '.yml'
        obj = YAML.load(realfilepath)
    obj

  parse: (filepath) ->
    obj = @_getObj(filepath)
    super(obj)

module.exports = Parser
