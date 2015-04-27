CSON = require 'CSON'
that = {}
that.parseJSONFile = CSON.parseJSONFile
that.parseCSONFile = CSON.parseCSONFile
{ extname } = require 'path'
{ FindType } = require './extractor'
{ join } = require 'path'

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

    endl = require '../index'
    containerInstance = endl.load(url).find(find)

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
      @_ext = extname(@_filepath)

  parse: ->
    if @_ext == '.json' or @_ext == '.cson'
      @_obj = that[if @_ext == '.json' then 'parseJSONFile' else 'parseCSONFile'](@_filepath)
      @_parse()
    else if @_ext == '.js' or @_ext == '.coffee'
      require(join(process.cwd(), @_filepath))
    else if @_obj?
      @_parse()

module.exports = Parser
