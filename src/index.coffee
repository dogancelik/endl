module.exports = require './core'
module.exports.file = (url, pageUrl) -> new (require('./file'))(url, pageUrl)
module.exports.parse = (filepath) -> (new (require('./parser'))(filepath)).parse()
