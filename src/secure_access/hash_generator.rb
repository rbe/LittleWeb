# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Create a hash.
  class HashGenerator
    require 'digest'
    require 'base64'

    def initialize
      @secret = 'YoungbloodEnigma'
      @md5 = Digest::SHA256.new
    end

    def to_base64(str)
      Base64.encode64(str).tr('+/', '-_').tr('=', '').strip
    end

    def make_md5(str)
      hash = @md5.digest "#{str} #{@secret}"
      to_base64 hash
    end
  end
end
