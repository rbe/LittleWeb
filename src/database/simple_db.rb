# frozen_string_literal: true

# Database
module Database
  # Simple database
  class SimpleDb
    require 'sqlite3'

    class << self
      DB_FILE = 'secure_access.db'

      # @param [String] stmt
      # @param [Boolean] single_tx
      def create_table(stmt, single_tx: false)
        SimpleDb.query do |db|
          db.transaction if single_tx
          db.execute stmt
          db.commit if single_tx
        end
      end

      # @param [String] stmt
      # @param [Boolean] single_tx
      def execute(stmt, single_tx: false)
        SimpleDb.query do |db|
          #db.transaction if single_tx
          results = db.execute stmt
          #db.commit if single_tx
          results
        end
      end

      def query(&block)
        return nil unless block_given?

        db = nil
        begin
          db = if File.exist? DB_FILE
                 SQLite3::Database.open DB_FILE
               else
                 SQLite3::Database.new DB_FILE
               end
          db.results_as_hash = true
          block.call(db)
        rescue SQLite3::Exception => e
          p e
        ensure
          begin
            db&.close
          rescue SQLite3::BusyException
            p 'SQLite is busy while trying to close db'
          end
        end
      end

      class << self
        def test_query
          SimpleDb.query do |db|
            db.execute <<-SQL
              CREATE TABLE IF NOT EXISTS csrf_token (
                csrf CHAR(44) UNIQUE,
                valid_until DATETIME DEFAULT (datetime('now', 'localtime', '+10 minutes'))
              )
            SQL
            db.execute 'INSERT INTO csrf_token (csrf) VALUES ("ABCDEFGHIJKLMNOPQRSTUVWXYZ123456")'
            results = db.query 'SELECT csrf FROM csrf_token'
            p results.inspect
            row = results.next
            p row['csrf']
            # results.each { |row| puts row }
          end
        end
      end
    end
  end
end
