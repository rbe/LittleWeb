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
        case @request.request_method
        when 'GET'
          proxy_file
        else
          @response.method_not_allowed
        end
      end

      private

      def proxy_file
        file = @request.request_uri
        file_path = "#{Constants::BASE_DIR}#{file}"
        if File.exist? file_path
          process_file file, file_path
        else
          @response.not_found 'Not found'
        end
      end

      def process_file(file, file_path)
        if file_path.end_with? '.adoc'
          render_asciidoc file_path
        else
          stream_file file, file_path
        end
      end

      def render_asciidoc(file_path)
        doc_renderer = DocRenderer::AsciidocRenderer.new
        content = doc_renderer.render file_path
        @response.success content
      end

      def stream_file(file, file_path)
        mime_type = MIME_TYPES.select { |k, _| file_path.end_with?(k.to_s) }.values.first
        if mime_type
          @response.success File.read(file_path, encoding: 'utf-8'), mime_type
        else
          @response.not_found "Unknown file type #{file}"
        end
      end
    end
  end
end
