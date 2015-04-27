Core = require './core'
File = require './file'

class Attr
  constructor: (@_url, @_find, @_findType, @_attr) ->
    @_attr = @_attr.toString()

  value: -> @_attr

  load: (options) ->
    url = @_attr
    Core.load(url, options)

  download: (options) ->
    url = @_attr
    pageUrl = @_url
    new File(url, pageUrl).download(options)

module.exports = Attr
