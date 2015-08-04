scraperjs = require 'scraperjs'
{ Extractor } = require './extractor'
{ _extend } = require 'util'

Core = {
  page: (url, options) ->
    options = options ? {}

    defaultOptions = {
      url: url
    }

    options = _extend(defaultOptions, options)

    if options.pageUrlAsReferrer is true
      if !options.headers?
        options.headers = {}
      if options.hasOwnProperty('previousUrl')
        options.headers.referer = options.previousUrl
      else
        options.headers.referer = url

    scraper = scraperjs.StaticScraper.create({
      url: options.url
      headers: options.headers
    })
    new Extractor(url, scraper)

  file: (url, pageUrl) ->
    File = require './file'
    new File(url, pageUrl)

  load: (filepath, downloadCb, extractCb) ->
    Parser = require './parser'
    new Parser().onDownload(downloadCb).onExtract(extractCb).parse(filepath)
}

module.exports = Core
