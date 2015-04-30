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

    if options.usePageUrlAsReferrer is true
      if !options.headers?
        options.headers = {}
      options.headers.referer = url

    scraper = scraperjs.StaticScraper.create({
      url: options.url
      headers: options.headers
    })
    new Extractor(url, scraper)

  file: (url, pageUrl) ->
    new (require('./file'))(url, pageUrl)

  load: (filepath) ->
    (new (require('./parser'))(filepath)).parse()
}

module.exports = Core
