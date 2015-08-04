mime = require 'mime'
url = require 'url'
{ parse } = url
path = require 'path'
{ normalize, dirname, basename, extname, join } = path
{ _extend } = require 'util'
{ createWriteStream, stat } = require 'fs'
sanitize = require 'sanitize-filename'
mkdirp = require 'mkdirp'
{ execFile } = require 'child_process'
Zip = require 'adm-zip'
minimatch = require 'minimatch'
bhttp = require 'bhttp'
{ EventEmitter } = require 'events'

class File
  constructor: (@_url, @_pageUrl) ->
    @_ee = new EventEmitter()

  # Binds a 'end' callback to response
  _bindCallback: (response, callback, data) ->
    if typeof callback == 'function'
      response.on 'end', -> callback(data)

  _getDefaultDownloadOptions: ->
    {
      headers: {}
      pageUrlAsReferrer: false
      filenameMode:
        contentDisposition: false
        urlBasename: false
        contentType: false
        predefined: false
        redirect: false
      directory: ''
    }

  _getExtension: (contentType) ->
    if contentType?
      extension = mime.extension(contentType)
      if extension?
        extension = ".#{extension}"
    extension

  _getFilename: (initialUrl, options, response) ->
    if typeof options.filenameMode.predefined is 'string'
      filename = sanitize(options.filenameMode.predefined)
    else if options.filenameMode.urlBasename == true
      if options.filenameMode.redirect == true
        filename = basename(parse(response.request.url).pathname) # Final URL after redirect
      else
        filename = basename(parse(initialUrl).pathname)
      filename = decodeURIComponent(filename) # %20 -> space
    # else if options.filenameMode.contentDisposition is true
    filename

  download: (options, callback) ->
    thisClass = @
    downloadUrl = @_url
    type = typeof options

    if type == 'string'
      options = {
        filenameMode:
          predefined: options
      }
    else if type == 'object' and Object.keys(options).length == 0
      options = {
        filenameMode:
          urlBasename: true
      }

    options = _extend(@_getDefaultDownloadOptions(), options)

    requestOptions = {
      headers: options.headers
      stream: true
      noDecode: true
    }

    if downloadUrl[0] == '/' and @_pageUrl.length > 0 # url doesn't have domain
      domain = url.resolve(@_pageUrl, '/').replace(/\/$/, '')
      downloadUrl = domain + downloadUrl

    if options.pageUrlAsReferrer is true
      requestOptions.headers.referer = if @_pageUrl then @_pageUrl else downloadUrl # good choice? prob not

    downloadCallback = (err, response) ->
      throw err if err

      contentType = response.headers['content-type']
      extension = thisClass._getExtension(contentType)
      filename = thisClass._getFilename(downloadUrl, options, response)

      # If filename has not extension same as contentType extension, add contentType extension if contentType is enabled
      if options.filenameMode.urlBasename == true and
        options.filenameMode.contentType == true and
        extension? and
        extension != extname(filename)
          filename += extension

      # If contentDisposition is enabled, check contentDisposition
      # If there is a filename, use that filename
      contentDisposition = response.headers['content-disposition']
      if options.filenameMode.contentDisposition == true and contentDisposition?
        cdFilename = contentDisposition.split('filename=')[1].replace(/"/g, '')
        if cdFilename.length > 0 then filename = sanitize(cdFilename)

      if !filename? then throw new Error('File name is not defined')

      # to do stat on empty directory string, you need to resolve first
      options.directory = path.resolve options.directory

      thisClass._file = join options.directory, filename

      callbackData = {
        url: downloadUrl
        file: thisClass._file
      }

      startDownload = ->
        thisClass._stream = createWriteStream thisClass._file
        thisClass._ee.emit 'create'
        File::_bindCallback(response, callback, callbackData)
        response.pipe thisClass._stream

      stat options.directory, (err, stats) ->
        if err and err.code == 'ENOENT'
          mkdirp options.directory, -> startDownload()
        else if not err
          startDownload()
        else
          throw err

    @_req = bhttp.get(downloadUrl, requestOptions, downloadCallback)
    @

  _getDefaultExtractOptions: ->
    {
      to: ''
      cd: false
      cdRegex: false
      fileGlob: false
      maintainEntryPath: true
      overwrite: true
    }

  _extractOnFinish: (options, callback) ->
    zip = new Zip(@_file)
    entries = zip.getEntries()

    options = _extend(@_getDefaultExtractOptions(), options)

    cdRegexSuffix = '([^\\\/\\\\]*(\\\/|\\\\))' # select everything until seperator including seperator
    cdRegex = null # keep it seperate from options
    if typeof options.cd is 'string' or typeof options.cdRegex is 'string'
      if typeof options.cd is 'string'
        cdRegex = new RegExp("^#{options.cd}#{cdRegexSuffix}")
      else if typeof options.cdRegex is 'string'
        cdRegex = new RegExp("#{options.cdRegex}#{cdRegexSuffix}")

      entries = entries.filter (entry) ->
        if cdRegex? then cdRegex.test entry.entryName else true

    if typeof options.fileGlob is 'string'
      entries = entries.filter (entry) ->
        minimatch(entry.name, options.fileGlob)

    extracted = []

    entries.forEach (entry) ->
      fromPath = entry.entryName

      if options.maintainEntryPath
        targetDirname = dirname(entry.entryName)

        if cdRegex != null
          targetDirname = targetDirname.replace(cdRegex, '')

        toPath = join(options.to, targetDirname)
      else
        toPath = options.to

      extracted.push {from: fromPath, to: toPath}
      zip.extractEntryTo(fromPath, toPath, false, options.overwrite)

    callback(extracted) if typeof callback == 'function'

  extract: (options, callback) ->
    thisClass = @
    thisClass._ee.on 'create', -> thisClass._stream.on('finish', thisClass._extractOnFinish.bind(thisClass, options, callback))

  _executeOnFinish: (options) ->
    if options instanceof Array
      args = options
      options = {}
    else if typeof options == 'object'
      args = options.args if options.hasOwnProperty('args')
    else
      options = options ? {}
    delete options.args
    execFile(@_file, args, options)

  execute: (options) ->
    thisClass = @
    thisClass._ee.on 'create', -> thisClass._stream.on('finish', thisClass._executeOnFinish.bind(thisClass, options))

module.exports = File
