{ tmpdir } = require 'os'
{ join } = require 'path'
endl = require '../src/index'

waitTime = 20000
urls = [
  'http://dogancelik.com'
  'http://lame.buanzo.org/'
  'https://github.com/request/request/archive/master.zip'
  'http://codecguide.com/download_k-lite_codec_pack_mega.htm'
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
      .extract {to: join(tmpdir(), '/unzip'), cd: 'request-master', fileGlob: '*.js', maintainEntryPath: false}, (extracted) ->
        if extracted.length == 0 then throw new Error('Zip is empty?')
        done()

describe 'endl test #4', ->

  it 'should use previousUrl', (done) ->
    endl.page(urls[3])
      .find('a[href^="http://downloads.ddigest.com/software/download.php"]')
      .page({ pageUrlAsReferrer: true })
      .find('a[href^="http://downloads.ddigest.com/software/getdownload.php?sid=1089"]',
        (container) ->
          referer = container._scraper.scraper.response.request.headers.referer
          if referer == urls[3]
            done()
          else
            throw new Error "Referrer is not initial URL: #{referer}"
      )
