#!/usr/bin/env ruby
# frozen_string_literal: true

# Tools for secure things
module SecureTools
  # Create a hash.
  # This has to match nginx configuration.
  class HashGenerator
    require 'digest'
    require 'base64'

    def initialize
      @secret = 'YoungbloodEnigma'
      @md5 = Digest::MD5.new
    end

    def make_md5(user, expires, url)
      hash = @md5.digest "#{user}#{expires}#{url} #{@secret}"
      Base64.encode64(hash).tr('+/', '-_').tr('=', '').strip
    end
  end
end

# Provide secure access to resources
module SecureAccess
  require_relative 'http'

  # Secure link request use case
  class SecureLinkRequestForm < HTTP::HttpResponse
    require 'cgi/html'
    require 'mail'

    # 2 hours in seconds
    EXPIRE_IN_SECONDS = 2 * 60 * 60

    # Standard cookie values
    STD_COOKIE = {
      'path' => '/',
      'domain' => 'localhost', # @cgi['SERVER_NAME'],
      'expires' => Time.now + EXPIRE_IN_SECONDS,
      'secure' => true,
      'httponly' => true
    }.freeze

    # Show form to request access
    def render
      headers = HTTP::STD_HEADERS.merge('status' => 200, 'type' => 'text/html')
      @cgi.out(headers) { @cgi.html('LANG' => 'de') { render_head + render_body } }
    end

    def process
      url = @cgi['url']
      expires = @cgi['expires']
      user = @cgi['user']
      hash = SecureTools::HashGenerator.new.make_md5(user, expires, url)
      cookies = create_cookies(expires, hash)
      send_mail
      redirect_with_cookie_response(cookies, url) # #{url}?md5=#{hash}&expires=#{expires}
    end

    private

    def send_mail
      mail = Mail.new do
        delivery_method :smtp, address: 'localhost', port: 1025
        from 'info@yourrubyapp.com'
        to 'your@bestuserever.com'
        subject 'Any subject you want'
        body 'Lorem Ipsum'
      end
      mail.deliver
    end

    def render_body
      @cgi.body do
        @cgi.h1 { 'Access Request Form' } +
          @cgi.form('METHOD' => 'POST', 'ENCTYPE' => 'text/json') do
            @cgi.text_field('NAME' => 'user', 'VALUE' => '', 'SIZE' => 50) +
              @cgi.submit('ID' => 'btn1', 'NAME' => 'btn1', 'VALUE' => 'OK')
          end
      end
    end

    def render_head
      @cgi.head do
        @cgi.title { 'Secure Access' }
      end
    end

    def create_cookies(expires, hash)
      [create_hash_cookie(hash), create_expires_cookie(expires)]
    end

    def create_expires_cookie(expires)
      CGI::Cookie.new(
        STD_COOKIE.merge(
          {
            'name' => 'secure_access_expires',
            'path' => '/',
            'value' => expires
          }
        )
      )
    end

    def create_hash_cookie(hash)
      CGI::Cookie.new(
        STD_COOKIE.merge(
          {
            'name' => 'secure_access_hash',
            'path' => '/',
            'value' => hash
          }
        )
      )
    end
  end
end
