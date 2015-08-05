{ tmpdir } = require 'os'
{ normalize } = require 'path'

replacer = {
  patterns: {
    tmpdir: {
      find: '%tmpdir%'
      replace: tmpdir
      after: normalize
    },
    env: {
      find: /%env:(\w+)%/gi,
      replace: (m, g1) -> process.env[g1]
    }
  }

  createRegex: (str) ->
    if typeof str == 'string'
      new RegExp(str, 'gi')
    else if str instanceof RegExp
      str
    else
      throw new Error 'This is not a string nor RegExp'

  replace: (str) ->
    oldStr = str
    for key, item of replacer.patterns
      find = replacer.createRegex(item.find)
      if find.test(str)
        # Not going to add any type checks for now
        str = str.replace(find, item.replace)
        [].concat(item.after).filter((i)-> typeof i == 'function').forEach (fix) -> str = fix(str)
    str
}

module.exports = replacer
