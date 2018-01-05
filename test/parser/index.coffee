endl = require '../../src/index'
{ tmpdir } = require 'os'
{ join } = require 'path'
fs = require 'fs'
{ expect } = require 'chai'

waitTime = 40000

describe "parser 'replacer' test", ->
  @timeout waitTime

  it 'should work', (done) ->
    endl.load join(__dirname, 'replacer.json'), (downloadData) ->
      expect(downloadData).to.be.an('object').that.have.all.keys('url', 'file')
      expect(fs.statSync.bind(fs, downloadData.file)).to.not.throw(Error)
      done()
    null

describe "parser 'extract' test", ->
  @timeout waitTime

  it 'should work', (done) ->
    endl.load join(__dirname, 'extract.json'), null, (extractData) ->
      expect(extractData).to.be.an('array').that.have.deep.property('[0].from').that.is.a('string').that.contains('.png')
      done()
    null

describe "parser 'then' test", ->
  @timeout waitTime

  i = 0

  it 'should work', (done) ->
    endl.load join(__dirname, 'then.json'), (downloadData) ->
      expect(downloadData).to.be.an('object').that.have.all.keys('url', 'file')
      expect(fs.statSync.bind(fs, downloadData.file)).to.not.throw(Error)
      done() if ++i == 2
    null
