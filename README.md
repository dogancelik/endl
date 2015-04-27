# *endl* (Extractor and Downloader) by Doğan Çelik
A program for extracting links from web pages and downloading them.

[![NPM](https://nodei.co/npm/endl.png?downloads=true&stars=true)](https://nodei.co/npm/endl/)

*endl* has a very simple also an advanced API for link extracting, file downloading, executing and unzipping.

**Every version under 1.0 is beta. This means it has bugs and features can change.**

## How to install?
[![NPM](https://nodei.co/npm/endl.png?mini=true)](https://nodei.co/npm/endl/)

*endl* has a command line shortcut!

## How do you pronounce *endl*?
Like *Handel* the composer, but without the *h* → *andel* :)

## Simple example
This is written in [*CoffeeScript*](https://github.com/jashkenas/coffeescript).

```coffee
endl = require 'endl'

endl.load('http://lame.buanzo.org/')
  .find('a[href^="http://lame.buanzo.org/Lame_"]')
  .download(pageUrlAsReferrer: true, filenameMode: { urlBasename: true })
```

### Explanation
1. We *require* our *endl* module. (Node style)
2. `endl.load()` loads the page we want. (It takes two arguments, second argument is an options *object* and optional.)
3. `find()` finds the elements we want. (Works just like jQuery and querySelectorAll)
4. Download our file to the current directory, using basename of our download link for file name and using our page URL as *Referer* header.

Things to note:
* We actually get 4 elements when we do `find()` but `download()` automatically selects the first element (0-index). Use `index()` to change index of element array.
* `download()` after `find()` is a shortcut. The long way is: *find(...)* → *href()* → *download(...)*

## Current issues
* findXpath doesn't work. Blame web pages (for incorrect structure), xmldom and xpath modules.

## To-Do
* Unify all downloading, extraction and execution options across submodules. (`endl.coffee`, `file.coffee`, `parser.coffee`) These 3 submodules have different *default* options for each task.
* Add tests in this century.

## More examples
### Example #1
Downloads PuTTY portable to the current directory.

```coffee
endl.load('http://portableapps.com/apps/internet/putty_portable')
  .find('.sf-download a')
  .load(pageUrlAsReferrer: true)
  .find('.direct-download')
  .download(pageUrlAsReferrer: true, filenameMode: { urlBasename: true })
```

If you do `load()` after *find* or *findXpath*, it will automatically load `href` attribute of the first element. (If you want to select another element, use `index()`)

If you do `download()` after *find* or *findXpath*, it will automatically download `href` attribute of the first element.

### Example #2
Downloads Lame for Windows and installs it silently.

```coffee
extractor.load('http://lame.buanzo.org/')
  .find('a[href^="http://lame.buanzo.org/Lame_"]')
  .download(
    pageUrlAsReferrer: true
    fileDirectory: './downloads'
    filenameMode: { urlBasename: true }
  )
  .execute('/VERYSILENT /NORESTART /LOG')
```
[Thanks to this blog for providing the arguments for silent install.](http://practicalschooltech.blogspot.com.tr/2013/11/silently-installing-audacity-and-lame.html)

### Example #3
Downloads Request (NodeJS module) and change directory of ZIP to `request-master`, extract all JS files to `./unzip`.

```coffee
endl.file('https://github.com/request/request/archive/master.zip')
  .download(pageUrlAsReferrer: true, filenameMode: { contentDisposition: true })
  .extract(to: './unzip', cd: 'request-master', fileGlob: '*.js', maintainEntryPath: false)
```

### CSON
This is just an example, you can use *JSON* too.

This example will download multiple files. It will extract the first item. It will install the second item.

```cson
[
  {
    url: 'http://www.mp3tag.de/en/download.html'
    find: 'div.download a'
    filenameMode: ['urlBasename', 'contentType']
  }
  {
    url: 'http://slimerjs.org/download.html'
    find: 'a.btn'
    findIndex: 4,
    filename: 'slimerjs.zip'
    extract:
      to: 'C:/slimerjs',
      cdRegex: '^slimerjs'
      fileGlob: '*.png'
      maintainEntryPath: false
  }
  {
    download: 'http://rammichael.com/downloads/7tt_setup.exe'
    execute: ['/S']
  }
]
```

### Command Line
```
endl d "http://www.mp3tag.de/en/download.html" "div.download a"
```
[Also check out Command Line page from Wiki](https://github.com/dogancelik/endl/wiki/Command-Line)

## API
[Check endl's API page](https://github.com/dogancelik/endl/wiki/API)
