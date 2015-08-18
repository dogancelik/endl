Core = require './core'
File = require './file'
{ preparePageOptions } = require './util'

class Attr
  constructor: (@_pageUrl, @_find, @_findType, @_attr) ->
    @_original = @_attr = @_attr.toString()
    @_attr = File::_getFullUrl(@_pageUrl, @_original)

  original: -> @_original

  value: (val) ->
    @_attr = val if val?
    @_attr

  page: (options) ->
    url = @_attr
    options = preparePageOptions(@_pageUrl, options)
    Core.page(url, options)

  download: -> # don't use params here, use arguments instead because better compability
    url = @_attr
    pageUrl = @_pageUrl
    fileInstance = new File(url, pageUrl)
    fileInstance.download.apply fileInstance, arguments

module.exports = Attr
