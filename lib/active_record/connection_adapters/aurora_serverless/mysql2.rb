require 'active_record/connection_adapters/aurora_serverless/mysql2/result'
require 'active_record/connection_adapters/aurora_serverless/mysql2/client'
require 'active_record/connection_adapters/aurora_serverless/mysql2/connection_handling'
require 'active_record/connection_adapters/aurora_serverless/gem_hack'
require 'active_record/connection_adapters/mysql2_adapter'

module ActiveRecord
  module ConnectionAdapters
    class AuroraServerlessAdapter < Mysql2Adapter
      include AuroraServerless::Abstract

      private

      def connect
        @connection = ConnectionHandling.aurora_serverless_connection_from_config(@config)
        configure_connection
      end

      # Abstract Mysql Adapter

      def translate_exception(exception, message:, sql:, binds:)
        ActiveRecord::StatementInvalid.new(message, sql: sql, binds: binds)
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
        1048576
      end

    end
  end
end
