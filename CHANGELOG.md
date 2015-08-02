# Changelog

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
