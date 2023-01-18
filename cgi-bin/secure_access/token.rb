# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  require 'base64'
  require_relative '../http/http_response'
  require_relative 'constants'
  require_relative 'hash_generator'

  # I am a token
  # user,url,expires -> base64
  class Token
    attr_reader :user, :url, :expires, :hash

    # Standard cookie values
    STD_COOKIE = {
      'domain' => 'localhost',
      'path' => '/',
      'expires' => Time.now + Constants::EXPIRE_IN_SECONDS,
      'secure' => false,
      'httponly' => true
    }.freeze

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

    # @param [String] str Base64 encoded string: user,url,expires
    def from_s(str)
      decoded = Base64.urlsafe_decode64(str).split(',')
      @user = decoded[0]
      @url = decoded[1]
      @expires = Time.at(decoded[2].to_i)
      to_hash
      self
    rescue ArgumentError
      @user = nil
      @url = nil
      @expires = nil
      @hash = nil
      self
    end

    # @param [CGI::Cookie] cookie
    def from_cookie(cookie)
      value = cookie.value.to_s.split(';')[0].split('=')[1]
      from_s value
    end

    def to_hash
      @hash = SecureAccess::HashGenerator.new.make_md5 "#{user}#{url}#{expires.to_i}"
    end

    def to_base64(str)
      Base64.urlsafe_encode64(str, padding: false)
    end

    def to_s
      to_base64 "#{user},#{url},#{expires.to_i}"
    end

    def bake_cookies
      [
        HTTP::HttpResponse.create_cookie('sx_token', to_s, STD_COOKIE),
        HTTP::HttpResponse.create_cookie('sx_hash', to_hash, STD_COOKIE)
      ]
    end

    def timed_out?
      Time.now >= @expires
    end

    def valid?(url)
      return false if @expires.nil?

      access?(user, url) && Time.now < @expires
    end

    def invalid?(url)
      !valid? url
    end

    # Check if a user has access to an URL
    def access?(user, url)
      if File.exist? Constants::SECURE_LINK_TXT
        lines = File.read(Constants::SECURE_LINK_TXT).split
        exact_match(lines, url, user) | partly_match(lines, url, user)
      else
        false
      end
    end

    # @param [String] other
    def ==(other)
      other.class == String && @hash.eql?(other)
    end

    alias eql? ==

    private

    def partly_match(lines, url, user)
      user_entries = lines.grep(/^.+:#{user}/)
      found = false
      user_entries.each do |entry|
        entry_url = entry.split(':')[0]
        if url.match(/#{entry_url}.*/)
          found = true
          break
        end
      end
      found
    end

    def exact_match(lines, url, user)
      grep = lines.grep(/^#{url}:#{user}/)
      grep.length == 1
    end
  end
end

t = SecureAccess::Token.new.with 'ralf@bensmann.com', '/Gallimaufry/IJOS-Stellenportal', Time.at(1_673_972_509)
# p t.access? 'ralf@bensmann.com', '/Gallimaufry/IJOS-Stellenportal/IJOS-Stellenportal.adoc'
h = "iFCPtcop0xvSF_CcDmwSyg"
p t == h
p t.hash == h
p t.hash.eql? h
p t.hash.eql? h
