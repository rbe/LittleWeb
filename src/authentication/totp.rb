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
      otp_secret = lookup_otp_secret user
      if otp_secret.empty?
        otp_secret = ROTP::Base32.random
        Database::SimpleDb.execute 'INSERT INTO totp (user, otp_secret)' \
                                       " VALUES (\"#{user}\", \"#{otp_secret}\")",
                                   single_tx: true
      end
      totp = ROTP::TOTP.new(otp_secret, issuer: Constants::OTP_ISSUER)
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
    # @param [String] otp_code
    def verify(user, otp_code)
      secs30 = (Time.now - 30).to_i
      otp_secret = lookup_otp_secret user
      return unless otp_secret

      totp = ROTP::TOTP.new(otp_secret, issuer: Constants::OTP_ISSUER)
      !totp.verify(otp_code.to_s, after: secs30).nil?
    end

    private

    def init_db
      Database::SimpleDb.create_table <<-SQL
        CREATE TABLE IF NOT EXISTS totp (
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
          , user VARCHAR(50) NOT NULL CHECK(user <> '') UNIQUE,
          , otp_secret CHAR(32) NOT NULL CHECK(otp_secret <> '') UNIQUE
        )
      SQL
    end

    # @param [String] user
    # @return [String] otp_secret
    def lookup_otp_secret(user)
      results = Database::SimpleDb.execute "SELECT otp_secret FROM totp WHERE user = \"#{user}\""
      return '' unless results&.length&.positive?

      row = results[0]
      row['otp_secret'] if row
    end

    class << self
      def test_generate_qrcode
        rotp = TOTP.new
        svg = rotp.generate_qrcode 'ralf@example.com'
        File.write 'otp_qrcode.svg', svg
      end

      def test_verify(totp)
        rotp = TOTP.new
        p rotp.verify 'ralf@example.com', totp
      end
    end
  end
end
