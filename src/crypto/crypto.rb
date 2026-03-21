# frozen_string_literal: true

# Cryptographic functions
module Crypto
  # Advanced Encryption Standard (AES)
  class AES
    require 'openssl'
    require 'base64'

    CIPHER = 'aes-256-cbc'

    def initialize(initv, key)
      @initv = initv
      @key = key
    end

    def encrypt(payload)
      cipher = OpenSSL::Cipher.new(CIPHER).encrypt
      cipher.iv = @initv
      cipher.key = @key
      encrypted = cipher.update(payload) + cipher.final
      Base64.strict_encode64(encrypted)
    end

    def decrypt(payload)
      decipher = OpenSSL::Cipher.new(CIPHER).decrypt
      decipher.iv = @initv
      decipher.key = @key
      decipher.update(Base64.strict_decode64(payload)) + decipher.final
    end

    class << self
      def test_encrypt(data = 'Hello!')
        iv = '0' * 16
        key = '0' * 32
        bla = Crypto::AES.new(iv, key)
        encrypted = bla.encrypt(data)
        decrypted = bla.decrypt(encrypted)
        p "#{data} -> #{encrypted} -> #{decrypted}"
        raise 'Error' unless data == decrypted
      end
    end
  end
end
