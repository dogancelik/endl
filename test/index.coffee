{ tmpdir } = require 'os'
{ join } = require 'path'
endl = require '../src/index'
{ expect } = require 'chai'

waitTime = 40000
urls = [
  'http://www.mediawiki.org/'
  'http://lame.buanzo.org/'
  'https://github.com/request/request/archive/master.zip'
  'http://codecguide.com/download_k-lite_codec_pack_mega.htm'
]

describe 'endl test #1', ->
  @timeout waitTime

  it 'should load page', (done) ->
    extractorInstance = endl.page(urls[0])
    extractorInstance._scraper.then (res) ->
      expect(res.statusCode).to.be.equal(200)
      done()
    null

  it 'should find element', (done) ->
    extractorInstance = endl.page(urls[0])
    extractorInstance.find '.mw-wiki-logo', (container) ->
      expect(container._getAttr('href')).to.be.equal('/wiki/MediaWiki')
      done()
    null

  it 'should resolve URL and download src', (done) ->
    extractorInstance = endl.page(urls[0])
    containerPromise = extractorInstance.find('#footer-copyrightico img')
    containerPromise.then (container) ->
      attrInstance = container.attr('src')
      attrInstance.download {filenameMode: {predefined: 'wikimedia.png'}, directory: tmpdir()}, -> done()
    null

describe 'endl test #2', ->
  @timeout waitTime

  qsa = 'a[href*=".exe"]'
  downloadOpts = { pageUrlAsReferrer: true, directory: tmpdir(), filenameMode: { urlBasename: true } }

  it 'should download', (done) ->
    endl.page(urls[1])
      .find(qsa)
      .then (container) ->
        container.download downloadOpts, -> done()
    null

  it 'should download all files with .all', (done) ->
    i = 0
    endl.page(urls[1])
      .find(qsa)
      .then (container) ->
        container.all().forEach (attr) ->
          attr.download downloadOpts, ->
            i++
            done() if i == 4
    null

describe 'endl test #3', ->
  @timeout waitTime

  it 'should download and unzip', (done) ->
    endl.file(urls[2])
      .download({ pageUrlAsReferrer: true, filenameMode: { contentDisposition: true }, directory: tmpdir()})
      .extract {to: join(tmpdir(), '/unzip'), cd: 'request-master', fileGlob: '*.js', maintainEntryPath: false}, (extracted) ->
        if extracted.length == 0 then throw new Error('Zip is empty?')
        done()
    null

describe 'endl test #4', ->

  it 'should use previousUrl', (done) ->
    endl.page(urls[3])
      .find('a[href^="http://www.majorgeeks.com/"]')
      .then (container) -> container.page({ pageUrlAsReferrer: true }).find('a[href*="getmirror/k_lite_mega_codec_pack"]')
      .then (container) ->
        expect(container._response.referer).to.be.equal(container._finalUrl.href.replace('https:', 'http:'))
        done()
    null
