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
    containerPromise = extractorInstance.find('#gif')
    containerPromise.then((container) ->
      attrInstance = container.attr('src')
      attrInstance.download {filenameMode: {predefined: 'gif.gif'}, directory: tmpdir()}, -> done()
    )

describe 'endl test #2', ->
  @timeout waitTime

  qsa = 'a[href^="http://lame.buanzo.org/Lame_"]'
  downloadOpts = {pageUrlAsReferrer: true, directory: tmpdir(), filenameMode: { urlBasename: true }}

  it 'should download', (done) ->
    endl.page(urls[1])
      .find(qsa)
      .then (container) ->
        container.download downloadOpts, -> done()

  it 'should download all files with .all', (done) ->
    i = 0
    endl.page(urls[1])
      .find(qsa)
      .then (container) ->
        container.all().forEach (attr) ->
          attr.download downloadOpts, ->
            i++
            done() if i == 4

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
      .find('a[href^="http://www.majorgeeks.com/"]')
      .then (container) ->
        container.page({ pageUrlAsReferrer: true })
          .find('a[href*="getmirror/k_lite_mega_codec_pack"]',
            (container) ->
              referer = container._scraper.scraper.response.request.headers.referer
              if referer == urls[3]
                done()
              else
                throw new Error "Referrer is not initial URL: #{referer}"
          )

describe 'endl test #5', ->
  @timeout waitTime

  it 'should parse json', (done) ->
    endl.load(join(__dirname, 'test.json'), null, -> done())
