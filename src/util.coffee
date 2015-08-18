{ _extend } = require 'util'

module.exports =
  preparePageOptions: (previousUrl, options) ->
    _extend { previousUrl: previousUrl }, options
