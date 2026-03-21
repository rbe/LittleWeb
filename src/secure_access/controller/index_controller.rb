# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Index controller
  module Controller
    require_relative '../../http/controller'

    # Index page
    class IndexController < HTTP::Controller
      def process
        case @request.request_method
        when 'GET'
          render_index
        else
          @response.method_not_allowed
        end
      end

      private

      def render_index
        render_view 'controller/views/index_page.slim'
      end
    end
  end
end