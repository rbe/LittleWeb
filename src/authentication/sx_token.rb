# frozen_string_literal: true

# sx: Secure Access
module Authentication
  # I am a token
  # user,url,expires -> base64
  class SxToken
    require 'base64'
    require_relative '../crypto/hash_generator'
    require_relative 'constants'

    attr_reader :user, :url, :expires, :hash

    # @param [String] user
    # @param [String] url
    # @param [Time] expires
    def with(user, url, expires = Time.now + Constants::EXPIRE_IN_SECONDS)
      @user = user
      @url = url
      @expires = expires
      to_hash
      self
    end

    # @param [String] token Base64 encoded string: user,url,expires
    def from_s(token)
      decoded = Base64.urlsafe_decode64(token).split(',')
      @user = decoded[0]
      @url = decoded[1]
      @expires = Time.at(decoded[2].to_i)
      to_hash
      self
    rescue ArgumentError
      reset
      self
    end

    # @param [CGI::Cookie] cookie
    def from_cookie(cookie)
      value = cookie.value.to_s.split(';')[0].split('=')[1]
      from_s value
    end

    # @param [String] cookie_value
    def from_cookie_value(cookie_value)
      from_s cookie_value
    end

    def to_hash
      @hash = Crypto::HashGenerator.new.make_md5 "#{user}#{url}#{expires.to_i}"
    end

    def to_base64(str)
      Base64.urlsafe_encode64(str, padding: false)
    end

    def to_s
      to_base64 "#{user},#{url},#{expires.to_i}"
    end

    # @param [HTTP::HttpRequest] request
    def bake_cookies(request)
      std = {
        'domain' => request.http_host_only,
        'path' => '/',
        'expires' => Time.now + Constants::EXPIRE_IN_SECONDS,
        'secure' => request.request_scheme == 'https',
        'httponly' => true,
        'samesite' => 'strict'
      }
      [
        HTTP::HttpResponse.create_cookie('sx_token', to_s, std),
        HTTP::HttpResponse.create_cookie('sx_hash', to_hash, std)
      ]
    end

    def timed_out?
      Time.now >= @expires
    end

    # @param [String] url
    def valid?(url)
      # TODO: Sanitize URL
      Time.now < @expires unless @user.nil? || url.nil? || @expires.nil?
    end

    # @param [String] other
    def ===(other)
      other.instance_of?(String) && @hash.eql?(other)
    end

    private

    def reset
      @user = nil
      @url = nil
      @expires = nil
      @hash = nil
    end

    class << self
      def test
        user = 'ralf@bensmann.com'
        url = '/Gallimaufry/IJOS-Stellenportal'
        expires = Time.at(1_673_972_509)
        t = Authentication::SxToken.new.with user, url, expires
        # TODO: p t.access? user, "#{url}/IJOS-Stellenportal.adoc"
        h = 'iFCPtcop0xvSF_CcDmwSyg'
        p t === h
        p t.hash == h
        p t.hash.eql? h
        p t.hash.eql? h
      end
    end
  end
end
