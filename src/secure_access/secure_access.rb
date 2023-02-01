#!/usr/bin/env ruby
# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  require_relative '../http/filter_chain'
  require_relative 'filter/honeypot_filter'
  require_relative 'filter/csrf_token_filter'
  require_relative 'filter/authentication_filter'
  require_relative 'filter/authorization_filter'
  require_relative 'dispatcher/front_dispatcher'

  PROTECTED_URLS = [
    %r{/*}
  ].freeze

  UNPROTECTED_URLS = [
    %r{^.*/registration.*$},
    %r{^.*/access_request.*$},
    %r{^.*/exchange.*$},
    %r{^.*/debug_.+},
    %r{^.*/$}
  ].freeze

  @request_filter_chain = [
    RequestFilter::HoneypotFilter.new,
    RequestFilter::CsrfTokenFilter.new,
    RequestFilter::AuthenticationFilter.new(PROTECTED_URLS, UNPROTECTED_URLS),
    RequestFilter::AuthorizationFilter.new
  ]

  def run
    cgi = CGI.new 'html5'
    request = HTTP::HttpRequest.new(cgi)
    response = HTTP::HttpResponse.new(cgi)
    HTTP::FilterChain.new(@request_filter_chain).filter(request, response)
    Dispatcher::FrontDispatcher.new(request, response).dispatch
  end

  module_function :run
end

def test_unauthenticated
  ENV['REQUEST_SCHEME'] = 'http'
  ENV['HTTP_HOST'] = 'localhost:8080'
  ENV['REQUEST_METHOD'] = 'GET'
  ENV['REQUEST_URI'] = '/Gallimaufry/IJOS-Stellenportal/IJOS-Stellenportal.adoc'
  ENV['QUERY_STRING'] = ''
end

def test_access_request
  ENV['REQUEST_SCHEME'] = 'http'
  ENV['HTTP_HOST'] = 'localhost'
  ENV['REQUEST_METHOD'] = 'POST'
  ENV['']
  ENV['REQUEST_URI'] = '/sx/access_request'
end

def test_exchange
  ENV['REQUEST_SCHEME'] = 'http'
  ENV['HTTP_HOST'] = 'localhost'
  ENV['REQUEST_METHOD'] = 'GET'
  ENV['REQUEST_URI'] = '/sx/exchange'
  ENV['QUERY_STRING'] = 'token=cmFsZkBleGFtcGxlLmNvbSwvR2FsbGltYXVmcnkvSUpPUy1TdGVsbGVucG9ydGFsL0lKT1MtU3RlbGxlbnBvcnRhbC5hZG9jLDE2NzUxMDQyMzQ&hash=gYowqniSaKBx6rtAg6wzaFzT8s1FkCYOErjE4uEhNcE'
end

def test_registration
  ENV['REQUEST_SCHEME'] = 'http'
  ENV['HTTP_HOST'] = 'localhost'
  ENV['REQUEST_METHOD'] = 'GET'
  ENV['REQUEST_URI'] = '/sx/registration'
end

def test_index
  ENV['REQUEST_SCHEME'] = 'http'
  ENV['HTTP_HOST'] = 'localhost'
  ENV['REQUEST_METHOD'] = 'GET'
  ENV['REQUEST_URI'] = '/sx'
end

SecureAccess.run
