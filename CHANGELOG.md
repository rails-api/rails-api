## master

* ActionDispatch::Head replaced by Rack::Head (@bearded)
* Converted Rails4 checks into Rails3 checks (@bearded)
* Green tests on Rails 5.0.0.alpha (@bearded)

## 0.3.0

* Use strong params on scaffolding (@txdavidtx)
* Add support for Rails 4.1 protected_instance_variables (@edowling)
* Fix rails-api new with --skip-active-record (@spastorino)

## 0.2.1

* Fix Rails 4.1 Gemfile generation issues (@neoeno, @RMaksymczuk,
  @spastorino)

## 0.2.0

* Rails 4.1 support (@jpteti, @litch, @bmorton)
* Add session management to Rails 4 stack if config.session\_store is
  supplied and config.api\_only = false (@tamird)

## 0.1.0

* Remove Ruby 1.9.2 support. (@steveklabnik)
* Ensure we require dependencies without security issues (@carlosantonio)
* Fix BestStandardsSupport, no longer in Rails 4 (@et)
* Remove old info about Rails from README (@garysweaver)
* Don't generate assets by default (@kjg)

## 0.0.3

* Add `config.api_only`, set it to false in case you want to use Rails default
  middleware stack. (@spastorino)
* Return proper format on exceptions. (@spastorino)
* Generate a specific `wrap_parameters` initializer, with commented out logic,
  since it's not enabled by default as the Rails template says.
* Remove `wrap_parameters` compatibility method, to allow enabling it if required.
* Require Rails >= 3.2.6.

## 0.0.2

* Use correct SSL middleware for Rails 3.2.x compatibility. (@philm)
* Add `helper` to compatibility methods for Rails 3.2.x. (@wintery)
* Add `helper_method` to compatibility methods for Rails 3.2.x. (@educobuci)
* Do not generate tmp and vendor directories. (@dpowell)
* Remove jquery-rails from generated Gemfile. (@dpowell)

## 0.0.1

* First release.
