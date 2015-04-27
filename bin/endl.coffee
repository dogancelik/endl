#!/usr/bin/env coffee

endl = require '../lib/index'
yargs = require('yargs')
{ parse } = require 'url'

argv = yargs
.usage('Usage: endl <command> (Page URL) (Find Query) [options]')
.command('d', 'Loads a page, finds an element, downloads a link')
.command('de', 'Same as d, but executes the file with arguments')
.command('dx', 'Same as d, but extracts the file with options')
.command('l', 'Load a JavaScript/CoffeeScript/JSON/CSON file')
.demand(1, 'You need to provide a command')
.option(
  't':
    type: 'string'
    alias: 'type'
    default: 'c'
    describe: 'Find type: c or x (cheerio or xpath)'
  'T':
    type: 'boolean'
    alias: 'text'
    default: false
    describe: 'Use text of element'
  'a':
    type: 'string'
    alias: 'attr'
    default: 'href'
    describe: 'Use an attribute of element',
  'm':
    type: 'string'
    alias: 'mode'
    default: 'urlBasename'
    describe: 'File name modes: urlBasename, contentType, contentDisposition (You can combine them with + character)'
  'd':
    type: 'string'
    alias: 'dir'
    default: ''
    describe: 'Sets download directory'
  'f':
    type: 'string'
    alias: 'filename'
    default: ''
    describe: 'Sets file name if no file name mode is specified'
  'r':
    type: 'boolean'
    alias: 'referrer'
    default: true
    describe: 'Uses page URL as referrer in download request'
  'to':
    type: 'string'
    default: ''
    describe: 'Extraction directory for compressed files'
  'cd':
    type: 'string'
    default: false
    describe: 'Change directory of compressed file (Normal mode)'
  'cdr':
    type: 'string'
    default: false
    describe: 'Change directory of compressed file (Regex mode)'
  'glob':
    type: 'string'
    default: false
    describe: 'File glob for extracting compressed file'
  'mep':
    type: 'boolean'
    default: true
    describe: 'Maintain entry path for compressed files'
  'or':
    type: 'boolean'
    alias: 'overwrite'
    default: true
    describe: 'Overwrite files when extracting'
  'args':
    type: 'string'
    default: ''
    describe: 'Arguments when executing file (Seperate arguments with "|", ex: "Hello|World|100")'
)
.help('h')
.alias('h', 'help')
.argv

[command, url, find] = argv._
useText = argv.T
attr = argv.a

if argv.f.length > 0
  useFilename = true
else
  useFilename = false

if argv.t == 'c'
  useCheerio = true
else
  useCheerio = false

downloadOptions = {}
downloadOptions.filenameMode = {}

if argv.f == ''
  argv.m.split('+').forEach (i) ->
    i = i.trim()
    downloadOptions.filenameMode[i] = true
else
  downloadOptions.filenameMode['predefined'] = argv.f

if command[0] == 'd'
  file = (endl.load(url)[if useCheerio then 'find' else 'findXpath'])(find).attr(attr).download(downloadOptions)

if command == 'de'
  execOptions = {
    args: argv.args.split('|')
  }

  file.execute(execOptions)
else if command == 'dx'
  extractOptions = {
    to: argv.to
    cd: argv.cd
    cdRegex: argv.cdr
    maintainEntryPath: argv.mep
    overwrite: argv.or
  }

  file.extract(extractOptions)
else if command = 'l'
  endl.parse(url)
