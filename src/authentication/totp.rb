# frozen_string_literal: true

# OTP
module Authentication
  require_relative 'constants'

  # OTP
  class TOTP
    require 'rotp'
    require 'rqrcode'
    require_relative '../database/simple_db'

    # => 'otpauth://totp/OTP_ISSUER:USER?secret=base32secret3232&issuer=OTP_ISSUER'
    # @param [String] user
    def generate_qrcode(user)
      secret = lookup_or_generate_secret(user)
      make_qrcode(secret, user)
    end

    # @param [String] user
    # @param [String] otp
    def verify_first_time(user, otp)
      return false unless verify user, otp

      Database::SimpleDb.execute 'UPDATE otp' \
                                 " SET validated_at = datetime('now', 'localtime')" \
                                 " WHERE user = '#{user}'",
                                 single_tx: true
      true
    end

    # @param [String] user
    # @param [String] otp
    def verify(user, otp)
      secs30 = (Time.now - 30).to_i
      secret = lookup_secret user
      return unless secret

      totp = ROTP::TOTP.new(secret, issuer: Constants::OTP_ISSUER)
      !totp.verify(otp.to_s, after: secs30).nil?
    end

    private

    def make_qrcode(secret, user)
      totp = ROTP::TOTP.new(secret, issuer: Constants::OTP_ISSUER)
      uri = totp.provisioning_uri(user)
      qrcode = RQRCode::QRCode.new(uri)
      qrcode.as_svg(
        color: '000',
        shape_rendering: 'crispEdges',
        module_size: 4,
        standalone: true,
        use_path: true
      )
    end

    def lookup_or_generate_secret(user)
      secret = lookup_secret user
      if secret.nil?
        secret = ROTP::Base32.random
        Database::SimpleDb.execute 'INSERT INTO otp (user, secret)' \
                                   " VALUES ('#{user}', '#{secret}')",
                                   single_tx: true
      end
      secret
    end

    # @param [String] user
    # @return [String] secret
    def lookup_secret(user)
      results = Database::SimpleDb.execute 'SELECT secret' \
                                           ' FROM otp' \
                                           " WHERE user = '#{user}'"
      return unless results&.length&.positive?

      row = results[0]
      row['secret'] if row
    end

    class << self
      def test_generate_qrcode
        totp = TOTP.new
        svg = totp.generate_qrcode 'ralf@example.com'
        File.write 'otp_qrcode.svg', svg
      end

      def test_verify(token)
        totp = TOTP.new
        p totp.verify 'ralf@example.com', token
      end
    end
  end
end
