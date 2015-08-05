endl = require '../src/index'
{ tmpdir } = require 'os'
{ replace } = require '../src/replacer'

describe 'replacer test #1', ->

  it 'should replace %tmpdir%', (done) ->
    done() if replace('%tmpdir%') == tmpdir()

  it 'should replace %env:TEST%', (done) ->
    done() if replace('%env:TEST%') == 'TEST123'
