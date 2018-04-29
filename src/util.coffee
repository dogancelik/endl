{ _extend } = require 'util'
rp = require 'request-promise'
cheerio = require 'cheerio'

module.exports =
  preparePageOptions: (previousUrl, options) ->
    _extend { previousUrl: previousUrl }, options
  
  FindType:
    jquery: 0
    qsa: 0
    cheerio: 0
    xpath: 1

  getDocument: (options) ->
    options.resolveWithFullResponse = true
    rp(options).then (res) ->
      finalUrl: res.request.uri
      body: res.body
      $: cheerio.load(res.body)
