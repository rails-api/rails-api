# Rails::API

[![Build Status](https://secure.travis-ci.org/rails-api/rails-api.png?branch=master)](http://travis-ci.org/rails-api/rails-api)

**Rails::API** is a subset of a normal Rails application, created for applications that don't require all functionality that a complete Rails application provides. It is a bit more lightweight, and consequently a bit faster than a normal Rails application. The main example for its usage is in API applications only, where you usually don't need the entire Rails middleware stack nor template generation.

## Using Rails for API-only Apps

This is a quick walk-through to help you get up and running with **Rails::API** to create API-only Apps, covering:

* What **Rails::API** provides for API-only applications
* How to decide which middlewares you will want to include
* How to decide which modules to use in your controller

### What is an API app?

Traditionally, when people said that they used Rails as an "API", they meant providing a programmatically accessible API alongside their web application.
For example, GitHub provides [an API](http://developer.github.com) that you can use from your own custom clients.

With the advent of client-side frameworks, more developers are using Rails to build a backend that is shared between their web application and other native applications.

For example, Twitter uses its [public API](https://dev.twitter.com) in its web application, which is built as a static site that consumes JSON resources.

Instead of using Rails to generate dynamic HTML that will communicate with the server through forms and links, many developers are treating their web application as just another client, consuming a simple JSON API.

This guide covers building a Rails application that serves JSON resources to an API client *or* client-side framework.

### Why use Rails for JSON APIs?

The first question a lot of people have when thinking about building a JSON API using Rails is: "isn't using Rails to spit out some JSON overkill? Shouldn't I just use something like Sinatra?"

For very simple APIs, this may be true. However, even in very HTML-heavy applications, most of an application's logic is actually outside of the view layer.

The reason most people use Rails is that it provides a set of defaults that allows us to get up and running quickly without having to make a lot of trivial decisions.

Let's take a look at some of the things that Rails provides out of the box that are still applicable to API applications.

#### Handled at the middleware layer:

* Reloading: Rails applications support transparent reloading. This works even if your application gets big and restarting the server for every request becomes non-viable.
* Development Mode: Rails application come with smart defaults for development, making development pleasant without compromising production-time performance.
* Test Mode: Ditto test mode.
* Logging: Rails applications log every request, with a level of verbosity appropriate for the current mode. Rails logs in development include information about the request environment, database queries, and basic performance information.
* Security: Rails detects and thwarts [IP spoofing attacks](http://en.wikipedia.org/wiki/IP_address_spoofing) and handles cryptographic signatures in a [timing attack](http://en.wikipedia.org/wiki/Timing_attack) aware way. Don't know what an IP spoofing attack or a timing attack is? Exactly.
* Parameter Parsing: Want to specify your parameters as JSON instead of as a URL-encoded String? No problem. Rails will decode the JSON for you and make it available in *params*. Want to use nested URL-encoded params? That works too.
* Conditional GETs: Rails handles conditional *GET*, (*ETag* and *Last-Modified*), processing request headers and returning the correct response headers and status code. All you need to do is use the [*stale?*](http://api.rubyonrails.org/classes/ActionController/ConditionalGet.html#method-i-stale-3F) check in your controller, and Rails will handle all of the HTTP details for you.
* Caching: If you use *dirty?* with public cache control, Rails will automatically cache your responses. You can easily configure the cache store.
* HEAD requests: Rails will transparently convert *HEAD* requests into *GET* requests, and return just the headers on the way out. This makes *HEAD* work reliably in all Rails APIs.

While you could obviously build these up in terms of existing Rack middlewares, I think this list demonstrates that the default Rails middleware stack provides a lot of value, even if you're "just generating JSON".

#### Handled at the ActionPack layer:

* Resourceful Routing: If you're building a RESTful JSON API, you want to be using the Rails router. Clean and conventional mapping from HTTP to controllers means not having to spend time thinking about how to model your API in terms of HTTP.
* URL Generation: The flip side of routing is URL generation. A good API based on HTTP includes URLs (see [the GitHub gist API](http://developer.github.com/v3/gists/) for an example).
* Header and Redirection Responses: `head :no_content` and `redirect_to user_url(current_user)` come in handy. Sure, you could manually add the response headers, but why?
* Basic, Digest and Token Authentication: Rails comes with out-of-the-box support for three kinds of HTTP authentication.
* Instrumentation: Rails 3.0 added an instrumentation API that will trigger registered handlers for a variety of events, such as action processing, sending a file or data, redirection, and database queries. The payload of each event comes with relevant information (for the action processing event, the payload includes the controller, action, params, request format, request method and the request's full path).
* Generators: This may be passé for advanced Rails users, but it can be nice to generate a resource and get your model, controller, test stubs, and routes created for you in a single command.
* Plugins: Many third-party libraries come with support for Rails that reduces or eliminates the cost of setting up and gluing together the library and the web framework. This includes things like overriding default generators, adding rake tasks, and honoring Rails choices (like the logger and cache backend).

Of course, the Rails boot process also glues together all registered components. For example, the Rails boot process is what uses your *config/database.yml* file when configuring ActiveRecord.

**The short version is**: you may not have thought about which parts of Rails are still applicable even if you remove the view layer, but the answer turns out to be "most of it".

### The Basic Configuration

If you're building a Rails application that will be an API server first and foremost, you can start with a more limited subset of Rails and add in features as needed.

**NOTE**: rails-api only supports Ruby 1.9.3 and above.

#### For new apps

Install the gem if you haven't already:

    gem install rails-api

Then generate a new **Rails::API** app:

    rails-api new my_api

This will do two main things for you:

* Make *ApplicationController* inherit from *ActionController::API* instead of *ActionController::Base*. As with middleware, this will leave out any *ActionController* modules that provide functionality primarily used by browser applications.
* Configure the generators to skip generating views, helpers and assets when you generate a new resource.

Rails includes all of the sub-frameworks (ActiveRecord, ActionMailer, etc) by default. Some API projects won't need them all, so at the top of config/application.rb, you can replace `require 'rails/all'` with specific sub-frameworks:

    # config/application.rb
    # require "active_record/railtie"
    require "action_controller/railtie"
    require "action_mailer/railtie"
    # require "sprockets/railtie"
    require "rails/test_unit/railtie"

This can also be achieved with flags when creating a new **Rails::API** app:

    rails-api new my_api --skip-active-record --skip-sprockets

Note: There are references to ActionMailer and ActiveRecord in the various
  config/environment files. If you decide to exclude any of these from your project
  its best to comment these out in case you need them later.

    # comment out this in config/environments/development.rb
    config.active_record.migration_error = :page_load
    config.action_mailer.raise_delivery_errors = false

    # comment out this in config/environments/test.rb
    config.action_mailer.delivery_method = :test


#### For already existing apps

If you want to take an existing app and make it a **Rails::API** app, you'll have to do some quick setup manually.

Add the gem to your *Gemfile*:

    gem 'rails-api'

And run `bundle` to install the gem.

Change *app/controllers/application_controller.rb*:

```ruby
# instead of
class ApplicationController < ActionController::Base
end

# do
class ApplicationController < ActionController::API
end
```

And comment out the `protect_from_forgery` call if you are using it. (You aren't using cookie-based authentication for your API, are you?)

If you want to use the Rails default middleware stack (avoid the reduction that rails-api does), you can just add `config.api_only = false` to `config/application.rb` file.

### Serialization

We suggest using [ActiveModel::Serializers][ams] to serialize your ActiveModel/ActiveRecord objects into the desired response format (e.g. JSON).
In `ApplicationController` you need to add `include ActionController::Serialization` to make ActiveModelSerializers work.



### Choosing Middlewares

An API application comes with the following middlewares by default.

* *ActionDispatch::DebugExceptions*: Log exceptions.
* *ActionDispatch::ParamsParser*: Parse XML, YAML and JSON parameters when the request's *Content-Type* is one of those.
* *ActionDispatch::Reloader*: In development mode, support code reloading.
* *ActionDispatch::RemoteIp*: Protect against IP spoofing attacks.
* *ActionDispatch::RequestId*: Makes a unique request id available, sending the id to the client via the X-Request-Id header. The unique request id can be used to trace a request end-to-end and would typically end up being part of log files from multiple pieces of the stack.
* *ActionDispatch::ShowExceptions*: Rescue exceptions and re-dispatch them to an exception handling application.
* *Rack::Cache*: Caches responses with public *Cache-Control* headers using HTTP caching semantics.
* *Rack::Head*: Dispatch *HEAD* requests as *GET* requests, and return only the status code and headers.
* *Rack::ConditionalGet*: Supports the `stale?` feature in Rails controllers.
* *Rack::ETag*: Automatically set an *ETag* on all string responses. This means that if the same response is returned from a controller for the same URL, the server will return a *304 Not Modified*, even if no additional caching steps are taken. This is primarily a client-side optimization; it reduces bandwidth costs but not server processing time.
* *Rack::Lock*: If your application is not marked as threadsafe (`config.threadsafe!`), this middleware will add a mutex around your requests.
* *Rack::Runtime*: Adds a header to the response listing the total runtime of the request.
* *Rack::Sendfile*: Uses a front-end server's file serving support from your Rails application.
* *Rack::Head*: Dispatch *HEAD* requests as *GET* requests, and return only the status code and headers.
* *Rails::Rack::Logger*: Log the request started and flush all loggers after it.

Other plugins, including *ActiveRecord*, may add additional middlewares. In general, these middlewares are agnostic to the type of app you are building, and make sense in an API-only Rails application.

You can get a list of all middlewares in your application via:

    rake middleware

#### Other Middlewares

Rails ships with a number of other middlewares that you might want to use in an API app, especially if one of your API clients is the browser:

* *Rack::MethodOverride*: Allows the use of the *_method* hack to route POST requests to other verbs.
* *ActionDispatch::Cookies*: Supports the *cookie* method in *ActionController*, including support for signed and encrypted cookies.
* *ActionDispatch::Flash*: Supports the *flash* mechanism in *ActionController*.
* *ActionDispatch::BestStandards*: Tells Internet Explorer to use the most standards-compliant available renderer. In production mode, if ChromeFrame is available, use ChromeFrame.
* Session Management: If a *config.session_store* is supplied and *config.api_only = false*, this middleware makes the session available as the *session* method in *ActionController*.

Any of these middlewares can be added via:

```ruby
config.middleware.use Rack::MethodOverride
```

#### Removing Middlewares

If you don't want to use a middleware that is included by default in the API middleware set, you can remove it using *config.middleware.delete*:

```ruby
config.middleware.delete ::Rack::Sendfile
```

Keep in mind that removing these features may remove support for certain features in *ActionController*.

### Choosing Controller Modules

An API application (using *ActionController::API*) comes with the following controller modules by default:

* *ActionController::UrlFor*: Makes *url_for* and friends available
* *ActionController::Redirecting*: Support for *redirect_to*
* *ActionController::Rendering*: Basic support for rendering
* *ActionController::Renderers::All*: Support for *render :json* and friends
* *ActionController::ConditionalGet*: Support for *stale?*
* *ActionController::ForceSSL*: Support for *force_ssl*
* *ActionController::RackDelegation*: Support for the *request* and *response* methods returning *ActionDispatch::Request* and *ActionDispatch::Response* objects.
* *ActionController::DataStreaming*: Support for *send_file* and *send_data*
* *AbstractController::Callbacks*: Support for *before_filter* and friends
* *ActionController::Instrumentation*: Support for the instrumentation hooks defined by *ActionController* (see [the source](https://github.com/rails/rails/blob/master/actionpack/lib/action_controller/metal/instrumentation.rb) for more).
* *ActionController::Rescue*: Support for *rescue_from*.

Other plugins may add additional modules. You can get a list of all modules included into *ActionController::API* in the rails console:

```ruby
ActionController::API.ancestors - ActionController::Metal.ancestors
```

#### Adding Other Modules

All Action Controller modules know about their dependent modules, so you can feel free to include any modules into your controllers, and all dependencies will be included and set up as well.

Some common modules you might want to add:

* *AbstractController::Translation*: Support for the *l* and *t* localization and translation methods. These delegate to *I18n.translate* and *I18n.localize*.
* *ActionController::HttpAuthentication::Basic::ControllerMethods* (or *Digest* or *Token*): Support for basic, digest or token HTTP authentication.
* *ActionView::Layouts*: Support for layouts when rendering.
* *ActionController::MimeResponds* (and *ActionController::ImplicitRender* for Rails 4): Support for content negotiation (*respond_to*, *respond_with*).
* *ActionController::Cookies*: Support for *cookies*, which includes support for signed and encrypted cookies. This requires the cookie middleware.

The best place to add a module is in your *ApplicationController*. You can also add modules to individual controllers.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Maintainers

* Santiago Pastorino (https://github.com/spastorino)
* Carlos Antonio da Silva (https://github.com/carlosantoniodasilva)
* Steve Klabnik (https://github.com/steveklabnik)

## License

MIT License.

## Mailing List

https://groups.google.com/forum/?fromgroups#!forum/rails-api-core

[ams]: https://github.com/rails-api/active_model_serializers
