Container = require './container'
xpath = require 'xpath'
{ DOMParser } = require 'xmldom'
deasync = require 'deasync'

FindType = {
  jquery: 0
  qsa: 0
  cheerio: 0
  xpath: 1
}

class Extractor
  constructor: (@_url, @_scraper) ->

  find: (query, callback) ->
    container = new Container(@_url, @_scraper, FindType.cheerio)

    done = false
    @_scraper.scrape(
      ($) ->
        container._find = $(query)
      , ->
        done = true
        if typeof callback == 'function' then callback(container)
    )
    while !done then deasync.runLoopOnce()

    container

  findXpath: (query, callback) ->
    container = new Container(@_url, @_scraper, FindType.xpath)

    done = false
    @_scraper.scrape(
      =>
        doc = new DOMParser().parseFromString(@_scraper.scraper.body, "text/html")
        nodes = xpath.select(query, doc)
        container._find = nodes
      , ->
        done = true
        if typeof callback == 'function' then callback(container)
    )
    while !done then deasync.runLoopOnce()

    container

exports.Extractor = Extractor
exports.FindType = FindType
