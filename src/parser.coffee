Core = require './core'
{ extname, join, isAbsolute } = require 'path'
{ FindType } = require './extractor'

class OnParser # Object notation parser, type agnostic
  _parse: ->
    @_iterate(if @_obj instanceof Array then @_obj else [ @_obj ])

  _iterate: (obj) ->
    obj.forEach (i) => @_iterateItem(i)

  _iterateItem: (item) ->
    url = item.url
    find = item.find
    findIndex = item.findIndex ? 0
    findType = FindType[item.findType ? 'cheerio']
    attr = item.attr ? 'href'
    useText = item.text ? false
    file = item.file ? false
    filename = item.filename ? false
    filenameMode = item.filenameMode ? ['urlBasename', 'contentType']
    execute = item.execute ? false
    extract = item.extract ? false

    containerInstance = Core.page(url).find(find)

    if findIndex != 0
      containerInstance = containerInstance.index(findIndex)

    if useText == true
      attrInstance = containerInstance.text()
    else
      attrInstance = containerInstance.attr(attr)

    downloadOptions = {}
    downloadOptions.filenameMode = filenameMode

    [].concat(filenameMode).forEach (i) ->
      downloadOptions.filenameMode[i] = true

    if typeof filename == 'string'
      downloadOptions.filenameMode['predefined'] = filename

    fileInstance = attrInstance.download(downloadOptions)

    if execute != false
      fileInstance.execute(execute)

    if extract != false
      console.log "extract", extract
      fileInstance.extract(extract)

class Parser extends OnParser
  constructor: (@_filepath) ->
    if typeof @_filepath == 'object'
      @_obj = @_filepath
    else
      @_realfilepath = if isAbsolute(@_filepath) then @_filepath else join(process.cwd(), @_filepath)
      @_ext = extname(@_filepath)

  parse: ->
    if @_ext == '.json'
      @_obj = require(@_realfilepath)
      @_parse()
    else if @_ext == '.yml'
      @_obj = YAML.load(@_realfilepath)
      @_parse()
    else if @_obj?
      @_parse()

module.exports = Parser
