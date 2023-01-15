#!/usr/bin/env ruby
# frozen_string_literal: true

# HTTP
module HTTP
  # Web server
  class WebServer
    require 'webrick'

    def initialize
      # Thread.new do
      create_server
      shutdown_hook
      start
    end

    private

    HTTP_PORT = 8999
    URL_PREFIX = '/cgi-bin'

    def create_server
      @server = WEBrick::HTTPServer.new(
        Port: HTTP_PORT,
        DocumentRoot: File.expand_path('.')
      )
      cgi_dir = File.expand_path('./cgi-bin')
      %w[/get_access].each do |u|
        @server.mount("#{URL_PREFIX}#{u}", WEBrick::HTTPServlet::CGIHandler, "#{cgi_dir}/dispatcher.rb")
      end
    end

    def shutdown_hook
      trap('INT') do
        puts 'Server shutdown'
        @server.shutdown
      end
    end

    def start
      puts "Starting Webrick on port #{HTTP_PORT}"
      @server.start
    end
  end
end

p $LOAD_PATH
HTTP::WebServer.new
