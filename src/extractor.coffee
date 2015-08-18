Container = require './container'
xpath = require 'xpath'
{ DOMParser } = require 'xmldom'
Promise = require 'bluebird'
{ FindType } = require './util'
scraperjs = require 'scraperjs'
{ _extend } = require 'util'

class Extractor
  constructor: (@_url, @_options) ->
    @_options ?= {}
    defaultOptions = url: @_url
    @_options = _extend defaultOptions, @_options

    if @_options.pageUrlAsReferrer is true
      if !@_options.headers?
        @_options.headers = {}
      if @_options.hasOwnProperty 'previousUrl'
        @_options.headers.referer = @_options.previousUrl
      else
        @_options.headers.referer = @_url

    @_scraper = scraperjs.StaticScraper.create
      url: @_options.url
      headers: @_options.headers

  find: (query, callback) ->
    container = new Container(@_url, @_scraper, FindType.cheerio)
    thisClass = this

    new Promise (resolve, reject) ->
      thisClass._scraper.scrape(
        ($) ->
          container._find = $(query)
        , ->
          callback(container) if typeof callback == 'function'
          resolve(container)
      )

  findXpath: (query, callback) ->
    container = new Container(@_url, @_scraper, FindType.xpath)
    thisClass = this

    new Promise (resolve, reject) ->
      thisClass._scraper.scrape(
        ->
          doc = new DOMParser().parseFromString(thisClass._scraper.scraper.body, "text/html")
          nodes = xpath.select(query, doc)
          container._find = nodes
        , ->
          callback(container) if typeof callback == 'function'
          resolve(container)
      )

module.exports = Extractor
