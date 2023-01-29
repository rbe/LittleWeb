# frozen_string_literal: true

# OTP
module Authentication
  require_relative 'constants'

  # OTP
  class TOTP
    require 'rotp'
    require 'rqrcode'
    require_relative '../database/simple_db'

    def initialize
      init_db
    end

    # => 'otpauth://totp/OTP_ISSUER:USER?secret=base32secret3232&issuer=OTP_ISSUER'
    # @param [String] user
    def generate_qrcode(user)
      secret = lookup_otp_secret user
      if secret.nil?
        secret = ROTP::Base32.random
        Database::SimpleDb.execute 'INSERT INTO otp (user, secret)' \
                                       " VALUES (\"#{user}\", \"#{secret}\")",
                                   single_tx: true
      end
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

    # @param [String] user
    # @param [String] otp
    def verify_first_time(user, otp)
      return unless verify user, otp

      Database::SimpleDb.execute "UPDATE validated_at = datetime('now', 'localtime') WHERE user = '#{user}'"
      true
    end

    # @param [String] user
    # @param [String] otp
    def verify(user, otp)
      secs30 = (Time.now - 30).to_i
      secret = lookup_otp_secret user
      return unless secret

      totp = ROTP::TOTP.new(secret, issuer: Constants::OTP_ISSUER)
      !totp.verify(otp.to_s, after: secs30).nil?
    end

    private

    def init_db
      Database::SimpleDb.create_table <<-SQL
        CREATE TABLE IF NOT EXISTS otp (
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
          , validated_at DATETIME CHECK(validated_at > created_at)
          , user VARCHAR(50) NOT NULL CHECK(user <> '') UNIQUE
          , secret CHAR(32) NOT NULL CHECK(secret <> '') UNIQUE
        )
      SQL
    end

    # @param [String] user
    # @return [String] secret
    def lookup_otp_secret(user)
      results = Database::SimpleDb.execute "SELECT secret FROM otp WHERE user = \"#{user}\""
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

# Authentication::TOTP.test_generate_qrcode
# Authentication::TOTP.test_verify 828309
