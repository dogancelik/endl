{ tmpdir } = require 'os'
endl = require '../src/index'

waitTime = 20000
urls = [
  'http://dogancelik.com'
  'http://lame.buanzo.org/'
  'https://github.com/request/request/archive/master.zip'
]

describe 'endl test #1', ->
  @timeout waitTime

  it 'should load page', (done) ->
    extractorInstance = endl.page(urls[0])
    extractorInstance._scraper.onStatusCode (code) ->
      code.should.be.equal 200
      done()

  it 'should find element', (done) ->
    extractorInstance = endl.page(urls[0])
    extractorInstance.find '#gif', (container) ->
      container._getAttr('alt').should.be.equal ':3'
      done()

  it 'should download src', (done) ->
    extractorInstance = endl.page(urls[0])
    attrInstance = extractorInstance.find('#gif').attr('src')
    attrInstance.download {filenameMode: {predefined: 'gif.gif'}, directory: tmpdir()}, -> done()

describe 'endl test #2', ->
  @timeout waitTime

  it 'should download', (done) ->
    endl.page(urls[1])
      .find('a[href^="http://lame.buanzo.org/Lame_"]')
      .download {pageUrlAsReferrer: true, directory: tmpdir(), filenameMode: { urlBasename: true }}, -> done()

describe 'endl test #3', ->
  @timeout waitTime

  it 'should download and unzip', (done) ->
    endl.file(urls[2])
      .download({pageUrlAsReferrer: true, filenameMode: { contentDisposition: true }, directory: tmpdir()})
      .extract {to: './unzip', cd: 'request-master', fileGlob: '*.js', maintainEntryPath: false}, (extracted) ->
        if extracted.length == 0 then throw new Error('Zip is empty?')
        done()
