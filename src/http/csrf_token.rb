# frozen_string_literal: true

# HTTP
module HTTP
  # CSRF
  class CsrfToken
    require 'securerandom'
    require 'digest'
    require_relative '../database/simple_db'

    def initialize(token = nil)
      init_db
      unless token
        token = CsrfToken.generate_token
        insert_token_db(token)
      end
      @token = token
    end

    def valid?
      results = Database::SimpleDb.execute "SELECT csrf FROM csrf_token WHERE csrf = \"#{@token}\""
      return false unless results

      if results.length == 1
        Database::SimpleDb.execute "DELETE FROM csrf_token WHERE csrf = \"#{@token}\""
        true
      else
        false
      end
    ensure
      cleanup
    end

    def to_s
      @token ? @token.to_s : ''
    end

    private

    def insert_token_db(token)
      Database::SimpleDb.execute "INSERT INTO csrf_token (csrf) VALUES (\"#{token}\")"
    ensure
      cleanup
    end

    def cleanup
      Database::SimpleDb.execute "DELETE FROM csrf_token WHERE valid_until < datetime('now', 'localtime', '+10 minutes')"
    end

    def init_db
      Database::SimpleDb.create_table <<-SQL
        CREATE TABLE IF NOT EXISTS csrf_token (
          csrf CHAR(44) UNIQUE
          , valid_until DATETIME DEFAULT (datetime('now', 'localtime', '+10 minutes'))
        )
      SQL
    end

    class << self
      def generate_token
        Digest::SHA256.base64digest SecureRandom.alphanumeric
      end

      def test_generate_token
        (1..10).each do |x|
          d = generate_token
          p "#{x}: #{d} -> #{d.length}"
        end
      end
    end
  end
end
