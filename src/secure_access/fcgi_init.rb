#!/usr/bin/env ruby
# frozen_string_literal: true

# Initialize database
module FcgiInit
  require_relative '../database/simple_db'

  def run
    Database::SimpleDb.create_table <<-SQL
        CREATE TABLE IF NOT EXISTS csrf_token (
            csrf CHAR(44) NOT NULL UNIQUE
          , valid_until DATETIME DEFAULT (datetime('now', 'localtime', '+5 minutes'))
        )
    SQL
    Database::SimpleDb.create_table <<-SQL
        CREATE TABLE IF NOT EXISTS otp (
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
          , validated_at DATETIME CHECK(validated_at > created_at)
          , user VARCHAR(50) NOT NULL CHECK(user <> '') UNIQUE
          , secret CHAR(32) NOT NULL CHECK(secret <> '') UNIQUE
        )
    SQL
  end

  module_function :run
end

FcgiInit.run
