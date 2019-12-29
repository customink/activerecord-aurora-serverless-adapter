require 'active_record/connection_adapters/aurora_serverless/mysql2/result'
require 'active_record/connection_adapters/aurora_serverless/mysql2/client'
require 'active_record/connection_adapters/aurora_serverless/mysql2/connection_handling'
require 'active_record/connection_adapters/aurora_serverless/gem_hack'
require 'active_record/connection_adapters/mysql2_adapter'

module ActiveRecord
  module ConnectionAdapters
    class AuroraServerlessAdapter < Mysql2Adapter
      include AuroraServerless::Abstract

      def self.name
        'Mysql2Adapter'
      end if ENV['AASA_ENV'] == 'test'

      def mysql2_connection(config)
        aurora_serverless_connection(config)
      end

      # Abstract Mysql Adapter

      def supports_advisory_locks?
        false
      end


      private

      def connect
        @connection = ConnectionHandling.aurora_serverless_connection_from_config(@config)
        configure_connection
      end

      # Abstract Mysql Adapter

      def translate_exception(exception, message)
        case message
        when /Duplicate entry/
          RecordNotUnique.new(message)
        when /foreign key constraint fails/
          InvalidForeignKey.new(message)
        when /Cannot add foreign key constraint/,
             /referenced column .* in foreign key constraint .* are incompatible/
          mismatched_foreign_key(message)
        when /Data too long for column/
          ValueTooLong.new(message)
        when /Out of range value for column/
          RangeError.new(message)
        when /Column .* cannot be null/,
             /Field .* doesn't have a default value/
          NotNullViolation.new(message)
        when /Deadlock found when trying to get lock/
          Deadlocked.new(message)
        when /Lock wait timeout exceeded/
          LockWaitTimeout.new(message)
        when /max_statement_time exceeded/, /Sort aborted/
          StatementTimeout.new(message)
        when /Query execution was interrupted/
          QueryCanceled.new(message)
        else
          ActiveRecord::StatementInvalid.new(message)
        end
      end

      # Database Statements

      def execute_batch(sql, name = nil)
        execute(sql, name)
      end

      def multi_statements_enabled?(flags)
        false
      end

      def with_multi_statements
        yield
      end

      def combine_multi_statements(total_sql)
        total_sql
      end

      def max_allowed_packet
        65536
      end

    end
  end
end
