# Changelog

## v1.1.0

* *(internal)* Dropped `scraperjs` dependency
* Fix ZIP extract

## v1.0.1

* Callbacks on *extract()* and *execute()* should ***finally*** work.

## v1.0.0

* Major version update (endl is not "experimental" anymore, no breaking changes).
* You can now use negative value on *Container.index()*.
* Use final URL when using *Referer* header.
* Callbacks on *extract()* and *execute()* should work properly now.

## v0.10.2

* Just some cleanup.

## v0.10.1

* `page()` in *Attr* and *Container* now both pass *previousUrl*.
* Fix crash if URL doesn't have domain in *File* class.

## v0.10.0

* You can now use *OnParser* recursively with `then` object (it also supports *Array* and *Object*).

## v0.9.3

* Fix no chaining support for *extract()* and *execute()*

## v0.9.2

* *extract()* and *execute()* now returns *File* instance. This means you can extract or execute more than once.
* You can now use *extract()* and *execute()* even when no method chaining is done.
* *extract()* and *execute()* will only execute *once per download()*.

**Explanation for the last bullet:** In previous versions, if you did: `download(...).extract(...).download(...)`, this would trigger *extract()* twice because we did `.on` bindings to the download stream instead of `.once`. Now if you ever download the file again within the same *File* instance, you have to use *extract()* again to extract it.

## v0.9.1

* *endl* should now resolve URLs without domains better in *download()* (e.g. If `href` is `/LatestSetup.exe` not `http://example.com/LatestSetup.exe`)

## v0.9.0

* *Container* class now assumes `href` as default attribute name. This means `attr(attrName)` will assume `href` if its first argument is null.
* There is a new function `all(attrName)` in *Container* class. It returns **an array** of *Attr* instances.
* `text()` in *Container* class now returns an *Attr* instance.
* `value(newValue)` in *Attr* class now supports getting and setting.

## v0.8.2

* Rewrote "pattern replacer". Parser now supports *%tmpdir%* and *%env:VARNAME%* for *directory* and *extract.to*.

## v0.8.1

* Fix new directory crash bug in *download()*

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
