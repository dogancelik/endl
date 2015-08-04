Container = require './container'
xpath = require 'xpath'
{ DOMParser } = require 'xmldom'
Promise = require 'bluebird'

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

exports.Extractor = Extractor
exports.FindType = FindType
