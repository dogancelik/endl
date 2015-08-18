Core =
  page: (url, options) ->
    Extractor = require './extractor'
    new Extractor(url, options)

  file: (url, pageUrl) ->
    File = require './file'
    new File(url, pageUrl)

  load: (filepath, downloadCb, extractCb) ->
    Parser = require './parser'
    new Parser().onDownload(downloadCb).onExtract(extractCb).parse(filepath)

module.exports = Core
