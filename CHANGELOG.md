## master

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
