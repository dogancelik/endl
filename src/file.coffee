mime = require 'mime'
{ parse } = require 'url'
{ normalize, dirname, basename, extname, join } = require 'path'
{ _extend } = require 'util'
{ createWriteStream, statSync } = require 'fs'
sanitize = require 'sanitize-filename'
request = require 'request'
mkdirp = require 'mkdirp'
deasync = require 'deasync'
{ execFile } = require 'child_process'
Zip = require 'adm-zip'
minimatch = require 'minimatch'


class File
  constructor: (@_url, @_pageUrl) ->

  download: (options) ->
    url = @_url
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
      fileDirectory: ''
    }

    if type is 'string'
      options = {
        filenameMode:
          predefined: options
      }
    else if type is 'object' and Object.keys(options).length is 0
      options = {
        filenameMode:
          urlBasename: true
      }

    options = _extend(defaultOptions, options)

    if typeof options.filenameMode.predefined is 'string'
      filename = sanitize(options.filenameMode.predefined)
    else if options.filenameMode.urlBasename == true
      filename = basename(parse(url).pathname)
    # else if options.filenameMode.contentDisposition is true

    downloadOptions = {
      url: url
      headers: options.headers
    }

    if options.pageUrlAsReferrer is true
      downloadOptions.headers.referer = @_pageUrl

    @_req = request(downloadOptions)

    @_req.on('response', (response) =>
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

        try
          statSync(options.fileDirectory)
        catch e
          if e.code == 'ENOENT'
            done = false
            mkdirp options.fileDirectory, -> done = true
            while !done then deasync.runLoopOnce()

        if !filename? then throw new Error("File name is not defined")

        @_file = join options.fileDirectory, filename
        @_stream = createWriteStream @_file
        @_req.pipe @_stream
      )

    @

  extract: (options) ->
    @_req.on 'end', =>
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

        cdRegexSuffix = '([^\\\/\\\\]+(\\\/|\\\\))' # select everything until seperator including seperator
        cdRegex = null # keep it seperate from options
        if typeof options.cd is 'string' or typeof options.cdRegex is 'string'
          entries = entries.filter (entry) ->
            if typeof options.cd is 'string'
              cdRegex = new RegExp("^#{options.cd}#{cdRegexSuffix}")
            else if typeof options.cdRegex is 'string'
              cdRegex = new RegExp("#{options.cdRegex}#{cdRegexSuffix}")

            if cdRegex? then cdRegex.test entry.entryName else true

        if typeof options.fileGlob is 'string'
          entries = entries.filter (entry) ->
            console.log entry.name, options.fileGlob
            minimatch(entry.name, options.fileGlob)

        console.log "entries", entries.length
        entries.forEach (entry) ->
          fromPath = entry.entryName

          if options.maintainEntryPath
            targetDirname = dirname(entry.entryName)

            if cdRegex != null
              targetDirname = targetDirname.replace(cdRegex, '')

            toPath = join(options.to, targetDirname)
          else
            toPath = options.to

          console.log("from", fromPath, "to", toPath)
          zip.extractEntryTo(fromPath, toPath, false, options.overwrite)

  execute: (options) ->
    @_req.on 'end', =>
      @_stream.on 'finish', =>
        options = options ? {}
        args = options.args ? null
        delete options.args
        execFile(@_file, args, options)

File::unzip = File::extract

module.exports = File
