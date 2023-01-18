# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  require_relative '../http/http_response'
  require_relative 'constants'
  require_relative '../doc_renderer/doc_renderer'

  # Simple proxy to retrieve files
  class SimpleProxy < HTTP::HttpResponse
    require 'cgi'

    def initialize(cgi)
      super(cgi)
      @doc_renderer = DocRenderer::DocRenderer.new
    end

    # @param [String] file
    def get_file(file)
      file_path = "#{Constants::BASE_DIR}#{file}"
      if File.exist? file_path
        if file_path.end_with? '.adoc', '.asciidoc'
          @cgi.out('text/html') { @doc_renderer.render file_path }
        elsif file_path.end_with? '.html'
          @cgi.out('text/html') { File.read(file_path, encoding: 'utf-8') }
        elsif file_path.end_with? '.css'
          @cgi.out('text/css') { File.read(file_path, encoding: 'utf-8') }
        elsif file_path.end_with? '.js'
          @cgi.out('text/javascript') { File.read(file_path, encoding: 'utf-8') }
        elsif file_path.end_with? '.svg'
          @cgi.out('image/svg+xml') { File.read(file_path, encoding: 'utf-8') }
        else
          bad_request_response "Access to #{file} not allowed"
        end
      else
        notfound_response
      end
    end
  end
end
