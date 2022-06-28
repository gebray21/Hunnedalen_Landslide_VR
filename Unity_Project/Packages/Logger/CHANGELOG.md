# Changelog

## Unreleased

### Added

* User can now set a global log-level
  * Log will now only print log-entries that are equal or of higher importance than the global log-level
* User can now add log-attributes
  * Log attributes can be added to classes or methods
  * These tags will override the global log-level and whichever is the lowest, will be considered
* User can now set the global loglevel through Log.Initialize()

### Changed

* Rename `Notice` log-level to `Info`
* Rename `Log.L()` to `Log.I()` to be more explicit
* Separating out types

## 0.0.9

* Initial release
