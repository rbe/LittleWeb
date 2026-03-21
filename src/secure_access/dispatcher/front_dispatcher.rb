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
        controller = select_controller.new(@request, @response)
        return @response.server_error 'Not processable' unless controller.processable?

        controller.process
      rescue StandardError => e
        @response.server_error "#{e.cause}, #{e.detailed_message}, #{e.backtrace&.join('\n').to_s}"
      end

      private

      def select_controller
        case full_request_uri
        when %r{^.*/registration.*$}
          Controller::OtpRegistrationController
        when %r{^.*/access_request$}
          Controller::AccessRequestController
        when %r{^.*/exchange.*$} # \?.+token=.+&hash=.+
          Controller::ExchangeController
        when %r{^.*/debug_.+}
          Controller::DebugTokenController
        when %r{^.*/$}
          Controller::IndexController
        else
          Controller::SimpleProxyController
        end
      end

      def full_request_uri
        uri = @request.request_uri
        uri += "?#{@request.query_string}" unless @request.query_string.empty?
        uri
      end
    end
  end
end
