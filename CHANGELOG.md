# Changelog

## v0.8.0

* Completely removed *deasync* module.
* *find()* and *findXpath()* uses *promises* now, thanks to *bluebird*. *Promise* will return *containerInstance*.

## v0.7.0

* *endl.load()* now supports two callbacks, first callback is called when download is finished, second is called when extraction is finished.
* *OnParser* (the parser that allows you to use *JSON*) supports *directory* option like *download()* does.

## v0.6.0

* *decodeURIComponent* is applied on file name when *urlBasename* is true.
* *endl.page()* option *usePageUrlAsReferrer* is changed to *pageUrlAsReferrer* for consistency.
* Fixed a bug where *extract()* would crash if no callback is provided.

## v0.5.0

* Fixed few bugs in Container class; you can now use Container.page() without any arguments.
* If usePageUrlAsReferrer is true (`endl.page()`), it will use previousUrl if previousUrl is defined in endl.page() otherwise it will use page URL.

## v0.4.0

* Removed *deasync* dependency in File class. *extract()* and *execute()* (kinda) are now asynchronous.
* *endl* uses *bhttp* instead of *needle*.

## v0.3.0

* Removed CSON, JS, CS and added YAML support for *endl.load()*
* Moved binary to *endl-cli*

## v0.2.0

* Changed `endl.load()` to `endl.page()`
* Changed `endl.parse()` to `endl.load()`
* Changed download option `fileDirectory` to `directory`
