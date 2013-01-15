require 'action_controller'
require 'action_controller/log_subscriber'

module ActionController
  # API Controller is a lightweight version of <tt>ActionController::Base</tt>,
  # created for applications that don't require all functionality that a complete
  # \Rails controller provides, allowing you to create faster controllers for
  # example for API only applications.
  #
  # An API Controller is different from a normal controller in the sense that
  # by default it doesn't include a number of features that are usually required
  # by browser access only: layouts and templates rendering, cookies, sessions,
  # flash, assets, and so on. This makes the entire controller stack thinner and
  # faster, suitable for API applications. It doesn't mean you won't have such
  # features if you need them: they're all available for you to include in
  # your application, they're just not part of the default API Controller stack.
  #
  # By default, only the ApplicationController in a \Rails application inherits
  # from <tt>ActionController::API</tt>. All other controllers in turn inherit
  # from ApplicationController.
  #
  # A sample controller could look like this:
  #
  #   class PostsController < ApplicationController
  #     def index
  #       @posts = Post.all
  #       render json: @posts
  #     end
  #   end
  #
  # Request, response and parameters objects all work the exact same way as
  # <tt>ActionController::Base</tt>.
  #
  # == Renders
  #
  # The default API Controller stack includes all renderers, which means you
  # can use <tt>render :json</tt> and brothers freely in your controllers. Keep
  # in mind that templates are not going to be rendered, so you need to ensure
  # your controller is calling either <tt>render</tt> or <tt>redirect</tt> in
  # all actions.
  #
  #   def show
  #     @post = Post.find(params[:id])
  #     render json: @post
  #   end
  #
  # == Redirects
  #
  # Redirects are used to move from one action to another. You can use the
  # <tt>redirect</tt> method in your controllers in the same way as
  # <tt>ActionController::Base</tt>. For example:
  #
  #   def create
  #     redirect_to root_url and return if not_authorized?
  #     # do stuff here
  #   end
  #
  # == Adding new behavior
  #
  # In some scenarios you may want to add back some functionality provided by
  # <tt>ActionController::Base</tt> that is not present by default in
  # <tt>ActionController::API</tt>, for instance <tt>MimeResponds</tt>. This
  # module gives you the <tt>respond_to</tt> and <tt>respond_with</tt> methods.
  # Adding it is quite simple, you just need to include the module in a specific
  # controller or in <tt>ApplicationController</tt> in case you want it
  # available to your entire app:
  #
  #   class ApplicationController < ActionController::API
  #     include ActionController::MimeResponds
  #   end
  #
  #   class PostsController < ApplicationController
  #     respond_to :json, :xml
  #
  #     def index
  #       @posts = Post.all
  #       respond_with @posts
  #     end
  #   end
  #
  # Quite straightforward. Make sure to check <tt>ActionController::Base</tt>
  # available modules if you want to include any other functionality that is
  # not provided by <tt>ActionController::API</tt> out of the box.
  class API < Metal
    abstract!

    module Compatibility
      def cache_store; end
      def cache_store=(*); end
      def assets_dir=(*); end
      def javascripts_dir=(*); end
      def stylesheets_dir=(*); end
      def page_cache_directory=(*); end
      def asset_path=(*); end
      def asset_host=(*); end
      def relative_url_root=(*); end
      def perform_caching=(*); end
      def helpers_path=(*); end
      def allow_forgery_protection=(*); end
      def helper_method(*); end
      def helper(*); end
    end

    extend Compatibility

    # Shortcut helper that returns all the ActionController::API modules except the ones passed in the argument:
    #
    #   class MetalController
    #     ActionController::API.without_modules(:Redirecting, :DataStreaming).each do |left|
    #       include left
    #     end
    #   end
    #
    # This gives better control over what you want to exclude and makes it easier
    # to create an api controller class, instead of listing the modules required manually.
    def self.without_modules(*modules)
      modules = modules.map do |m|
        m.is_a?(Symbol) ? ActionController.const_get(m) : m
      end

      MODULES - modules
    end

    MODULES = [
      HideActions,
      UrlFor,
      Redirecting,
      Rendering,
      Renderers::All,
      ConditionalGet,
      RackDelegation,

      ForceSSL,
      DataStreaming,

      # Before callbacks should also be executed the earliest as possible, so
      # also include them at the bottom.
      AbstractController::Callbacks,

      # Append rescue at the bottom to wrap as much as possible.
      Rescue,

      # Add instrumentations hooks at the bottom, to ensure they instrument
      # all the methods properly.
      Instrumentation
    ]

    MODULES.each do |mod|
      include mod
    end

    ActiveSupport.run_load_hooks(:action_controller, self)
  end
end
