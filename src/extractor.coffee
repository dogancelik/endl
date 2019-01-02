Container = require './container'
xpath = require 'xpath'
{ DOMParser } = require 'xmldom'
{ FindType, getDocument } = require './util'
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

    @_scraper = getDocument
      uri: @_options.url
      headers: @_options.headers

  find: (query, callback) ->
    container = new Container(@_url, @_scraper, FindType.cheerio)
    thisClass = this

    thisClass._scraper.then (res) ->
      container._find = res.$(query)
      container._finalUrl = res.finalUrl
      callback(container) if typeof callback == 'function'
      container

  findXpath: (query, callback) ->
    container = new Container(@_url, @_scraper, FindType.xpath)
    thisClass = this

    thisClass._scraper.then (res) ->
      doc = new DOMParser().parseFromString(res.body, 'text/html')
      nodes = xpath.select(query, doc)
      container._find = nodes
      callback(container) if typeof callback == 'function'

module.exports = Extractor
