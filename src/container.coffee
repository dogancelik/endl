Attr = require './attr'
that = this

class Container
  constructor: (@_url, @_scraper, @_findType) ->
    @_index = 0

    extractor = require './extractor'
    that.FindType = extractor.FindType

  load: (attrName, options) ->
    targetAttr = null

    if typeof attrName is 'object' # attrName is options, attrName assumed 'href'
      targetAttr = 'href'
      targetOptions = attrName
    else if typeof attrName is 'string'
      targetAttr = attrName
      targetOptions = options

    url = @_getAttr(targetAttr)

    require('./core').load(url, targetOptions)

  _getAttr: (attrName) ->
    if @_findType is that.FindType.cheerio
      @_attr = @_find[@_index].attribs[attrName]
    else if @_findType is that.FindType.xpath
      console.log "xpath", @_find
      @_attr = @_find.attributes.getNamedItem(attrName).value

    @_attr

  attr: (attrName) ->
    @_getAttr(attrName)
    new Attr @_url, @_find, @_findType, @_attr

  href: (attrName) -> @attr('href')

  text: ->
    if @_findType is that.FindType.cheerio
      @_attr = @_find.index(@_index).text()
    else if @_findType is that.FindType.xpath
      @_attr = @_find.textContent

  index: (index) ->
    @_index = index
    @

  download: (options) ->
    @href().download(options)

module.exports = Container
