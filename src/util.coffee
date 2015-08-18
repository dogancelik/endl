{ _extend } = require 'util'

module.exports =
  preparePageOptions: (previousUrl, options) ->
    _extend { previousUrl: previousUrl }, options
  
  FindType:
    jquery: 0
    qsa: 0
    cheerio: 0
    xpath: 1
