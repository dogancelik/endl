Attr = require './attr'
{ _extend } = require 'util'
that = this

class Container
  constructor: (@_pageUrl, @_scraper, @_findType) ->
    @_index = 0
    @_attrName = 'href'

    extractor = require './extractor'
    that.FindType = extractor.FindType

  page: (attrName, options) ->
    targetAttr = 'href'
    targetOptions = {}

    if typeof attrName is 'object' # attrName is options, attrName assumed 'href'
      targetAttr = 'href'
      targetOptions = attrName
    else if typeof attrName is 'string'
      targetAttr = attrName
      targetOptions = options

    url = @_getAttr(targetAttr)
    targetOptions = _extend({ previousUrl: @_pageUrl }, targetOptions)

    # to avoid circular dependency problem, we put here
    require('./core').page(url, targetOptions)

  _getAttr: (attrName, index) ->
    attrName ?= @_attrName
    index ?= @_index

    if @_findType is that.FindType.cheerio
      _attr = @_find[index].attribs[attrName]
    else if @_findType is that.FindType.xpath
      _attr = @_find.attributes.getNamedItem(attrName).value

    _attr

  attr: (attrName, index, _attr) ->
    _attr ?= @_getAttr(attrName, index)
    new Attr @_pageUrl, @_find, @_findType, _attr

  all: (attrName) ->
    if @_findType is that.FindType.cheerio
      @attr(attrName, index) for index in [0..@_find.length-1]
    else
      [attr(attrName)]

  href: -> @attr('href')

  text: ->
    if @_findType is that.FindType.cheerio
      _attr = @_find.index(@_index).text()
    else if @_findType is that.FindType.xpath
      _attr = @_find.textContent

    attr(null, null, _attr)

  index: (index) ->
    @_index = index
    @

  download: ->
    attrInstance = @href()
    attrInstance.download.apply attrInstance, arguments

module.exports = Container
