# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Controller
  module Controller
    require_relative '../../http/controller'

    # Simple proxy to retrieve files
    class SimpleProxyController < HTTP::Controller
      require_relative '../../doc_renderer/asciidoc_renderer'
      require_relative 'constants'

      MIME_TYPES = {
        '.adoc': 'text/html',
        '.asciidoc': 'text/html',
        '.html': 'text/html',
        '.css': 'text/css',
        '.js': 'text/javascript',
        '.svg': 'image/svg+xml'
      }.freeze

      def process
        file = @request.request_uri
        file_path = "#{Constants::BASE_DIR}#{file}"
        if File.exist? file_path
          process_file(file, file_path)
        else
          @response.notfound_response
        end
      end

      private

      def process_file(file, file_path)
        if file_path.end_with? '.adoc'
          render_asciidoc(file_path)
        else
          stream_file(file, file_path)
        end
      end

      def render_asciidoc(file_path)
        doc_renderer = DocRenderer::AsciidocRenderer.new
        content = doc_renderer.render file_path
        @response.success_response content
      end

      def stream_file(file, file_path)
        mime_type = MIME_TYPES.select { |k, _| file_path.end_with? k }
        if mime_type
          @cgi.out(mime_type) { File.read(file_path, encoding: 'utf-8') }
        else
          @response.bad_request_response "Unknown file type #{file}"
        end
      end
    end
  end
end
