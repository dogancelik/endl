Core = require './core'
File = require './file'

class Attr
  constructor: (@_pageUrl, @_find, @_findType, @_attr) ->
    @_attr = @_attr.toString()

  value: -> @_attr

  page: (options) ->
    url = @_attr
    Core.page(url, options)

  download: -> # don't use params here, use arguments instead because better compability
    url = @_attr
    pageUrl = @_pageUrl
    fileInstance = new File(url, pageUrl)
    fileInstance.download.apply fileInstance, arguments

module.exports = Attr
