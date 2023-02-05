# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Dispatcher
  module Dispatcher
    require_relative '../../http/dispatcher'

    # Front dispatcher
    class FrontDispatcher
      include HTTP::Dispatcher

      require_relative '../controller/index_controller'
      require_relative '../controller/otp_registration_controller'
      require_relative '../controller/access_request_controller'
      require_relative '../controller/exchange_controller'
      require_relative '../controller/simple_proxy_controller'
      require_relative '../controller/debug_token_controller'

      def initialize(request, response)
        @request = request
        @response = response
      end

      # Dispatch
      def dispatch
        # TODO: Generify
        controller = case full_request_uri
                     when %r{^.*/registration.*$}
                       Controller::OtpRegistrationController.new(@request, @response)
                     when %r{^.*/access_request$}
                       Controller::AccessRequestController.new(@request, @response)
                     when %r{^.*/exchange.*$} # \?.+token=.+&hash=.+
                       Controller::ExchangeController.new(@request, @response)
                     when %r{^.*/debug_.+}
                       Controller::DebugTokenController.new(@request, @response)
                     when %r{^.*/$}
                       Controller::IndexController.new(@request, @response)
                     else
                       Controller::SimpleProxyController.new(@request, @response)
                     end
        return @response.server_error 'Not processable' unless controller.processable?

        controller.process
        # rescue StandardError => e
        # handle_error(e)
      end

      private

      def full_request_uri
        uri = @request.request_uri
        uri += "?#{@request.query_string}" unless @request.query_string.empty?
        uri
      end
    end
  end
end
