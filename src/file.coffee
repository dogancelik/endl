mime = require 'mime'
url = require 'url'
{ parse } = url
path = require 'path'
{ normalize, dirname, basename, extname, join } = path
{ _extend } = require 'util'
{ createWriteStream, stat } = require 'fs'
sanitize = require 'sanitize-filename'
mkdirp = require 'mkdirp'
deasync = require 'deasync'
{ execFile } = require 'child_process'
Zip = require 'adm-zip'
minimatch = require 'minimatch'
needle = require 'needle'
{ runLoopOnce } = require 'deasync'

class File
  constructor: (@_url, @_pageUrl) ->

  download: (options, callback) ->
    thisClass = @
    downloadUrl = @_url
    type = typeof options

    defaultOptions = {
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

    options = _extend(defaultOptions, options)

    if typeof options.filenameMode.predefined is 'string'
      filename = sanitize(options.filenameMode.predefined)
    else if options.filenameMode.urlBasename == true
      filename = basename(parse(downloadUrl).pathname)
    # else if options.filenameMode.contentDisposition is true

    downloadOptions = {
      headers: options.headers
      follow_max: 10
    }

    if downloadUrl[0] == '/' and @_pageUrl.length > 0 # url doesn't have domain
      domain = url.resolve(@_pageUrl, '/').replace(/\/$/, '')
      downloadUrl = domain + downloadUrl

    if options.pageUrlAsReferrer is true
      downloadOptions.headers.referer = if @_pageUrl then @_pageUrl else downloadUrl # good choice? prob not

    downloadCallback = (err, response) ->
      throw err if err

      contentType = response.headers['content-type']
      if contentType?
        extension = mime.extension(contentType)
        extension = ".#{extension}"

      # If filename has not extension same as contentType extension, add contentType extension if contentType is enabled
      if options.filenameMode.urlBasename == true and
        options.filenameMode.contentType == true and
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
        thisClass._stream.on 'finish', -> callback(callbackData) if typeof callback == 'function'
        thisClass._stream.end response.raw

      stat options.directory, (err, stats) ->
        if err and err.code == 'ENOENT'
          mkdirp options.directory, -> startDownload()
        if not err
          startDownload()
        else
          throw err

    @_req = needle.get(downloadUrl, downloadOptions, downloadCallback)
    @

  extract: (options, callback) ->
    while !@_stream then runLoopOnce()
    @_stream.on 'finish', =>
      zip = new Zip(@_file)
      entries = zip.getEntries()

      defaultOptions = {
        to: ''
        cd: false
        cdRegex: false
        fileGlob: false
        maintainEntryPath: true
        overwrite: true
      }

      options = _extend(defaultOptions, options)

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

      callback(extracted)

  execute: (options) ->
    while !@_stream then runLoopOnce()
    @_stream.on 'finish', =>
      if options instanceof Array
        args = options
        options = {}
      else if typeof options == 'object'
        args = options.args if options.hasOwnProperty('args')
      else
        options = options ? {}
      delete options.args
      execFile(@_file, args, options)

module.exports = File
