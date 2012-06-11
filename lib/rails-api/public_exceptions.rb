module Rails
  module API
    class PublicExceptions
      def initialize
        @fallback = ActionDispatch::PublicExceptions.new(Rails.public_path)
      end

      def call(env)
        exception    = env["action_dispatch.exception"]
        status       = env["PATH_INFO"][1..-1]
        request      = ActionDispatch::Request.new(env)
        content_type = request.formats.first
        body         = { :status => status, :error => exception.message }

        format = "to_#{Mime[content_type].to_sym}"
        if body.respond_to?(format)
          body = body.public_send(format)
          [status, {'Content-Type' => "#{content_type}; charset=#{ActionDispatch::Response.default_charset}",
                    'Content-Length' => body.bytesize.to_s}, [body]]
        else
          @fallback.call(env)
        end
      end
    end
  end
end
