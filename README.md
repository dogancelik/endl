![endl-banner](https://cloud.githubusercontent.com/assets/486818/9147568/65481174-3d71-11e5-86c4-27f0647c37dc.png)

[![Build Status](https://travis-ci.org/dogancelik/endl.svg?branch=master)](https://travis-ci.org/dogancelik/endl)

*endl* is a Node.js module for extracting links from web pages and downloading them.

[![NPM](https://nodei.co/npm/endl.png?downloads=true&stars=true)](https://nodei.co/npm/endl/)

| [Changelog](https://github.com/dogancelik/endl/blob/master/CHANGELOG.md) | [API](https://github.com/dogancelik/endl/wiki/API) | [Examples](https://github.com/dogancelik/endl/wiki/Examples) | [CLI](https://github.com/dogancelik/endl-cli) | [To-Do List](https://trello.com/b/GIu0Rooi)
|:-:|:-:|:-:|:-:|:-:|

*endl* has a very simple also an advanced API for link extracting, file downloading, executing and unzipping.

:exclamation: Every version under 1.0 is *experimental*. Features work but they may have bugs or they can change in next versions so you should also pay attention to the changelog frequently. :exclamation:

## Simple example
```js
var endl = require('endl');

endl
  .page('http://lame.buanzo.org/')
  .find('a[href^="http://lame.buanzo.org/Lame_"]') # returns Promise
  .then(function(container) {
    container.download({
      pageUrlAsReferrer: true,
      filenameMode: { urlBasename: true }
    });
  });
```

### Explanation
1. We *require* our *endl* module.
2. `endl.page()` loads the page we want. (It takes two arguments, second argument is an options *object* and optional.)
3. `find()` finds the elements we want. (Works just like jQuery and querySelectorAll) but it is a Promise that returns a *containerInstance*
4. Download our file to the current directory, using basename of our download link for file name and using our page URL as *Referer* header.

Things to note:
* We actually get 4 elements when we do `find()` but `download()` automatically selects the first element (0-index). Use `index()` to change index of element array.
* `download()` after `find()` is a shortcut. The long way is: *find(...)* → *href()* → *download(...)*

## Install
```
npm install endl
```

Prerequisites: Tools for building NodeJS native modules (Visual Studio or [Visual Studio Express](https://www.visualstudio.com/en-us/products/visual-studio-express-vs.aspx))

## How do you pronounce *endl*?
Like *Handel* the composer, but without the *h* → *andel* :)

## Current issues
* findXpath doesn't work. Blame web pages (for incorrect structure), xmldom and xpath modules.

## To-Do
[To-do list is at Trello](https://trello.com/b/GIu0Rooi) (You can vote on notes)

If you don't have a Trello account and want to vote, [you can use my referral link to register](https://trello.com/dogancelik/recommend) (They just give a month of free Gold membership for each referral so I can add custom background images to the board :smile:)
