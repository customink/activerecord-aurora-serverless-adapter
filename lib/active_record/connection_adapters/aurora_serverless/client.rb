module ActiveRecord
  module ConnectionAdapters
    module AuroraServerless
      class Client
        attr_reader :database,
                    :resource_arn,
                    :secret_arn,
                    :raw_client,
                    :affected_rows,
                    :last_id

        def initialize(database, resource_arn, secret_arn, options = {})
          @database = database
          @resource_arn = resource_arn
          @secret_arn = secret_arn
          @raw_client = Aws::RDSDataService::Client.new(client_options(options))
          @transactions = Concurrent::Array.new
          @affected_rows = 0
        end

        def inspect
          "#<#{self.class} database: #{database.inspect}, raw_client: #{raw_client.inspect}>"
        end

        def execute_statement(sql)
          raw_client.execute_statement({
            sql: sql,
            database: database,
            secret_arn: secret_arn,
            resource_arn: resource_arn,
            include_result_metadata: true,
            transaction_id: @transactions.first
          }).tap do |r|
            @affected_rows = affected_rows_result(r)
            @last_id = last_id_result(r)
          end
        end

        def begin_db_transaction
          @transactions.unshift(raw_client.begin_transaction({
            database: database,
            secret_arn: secret_arn,
            resource_arn: resource_arn
          }).transaction_id)
        end

        def commit_db_transaction
          id = @transactions.pop
          raw_client.commit_transaction({
            secret_arn: secret_arn,
            resource_arn: resource_arn,
            transaction_id: id
          }) if id
        end

        def exec_rollback_db_transaction
          id = @transactions.pop
          raw_client.rollback_transaction({
            secret_arn: secret_arn,
            resource_arn: resource_arn,
            transaction_id: id
          }) if id
        end

        private

        def client_options(options)
          options.except :idle_timeout
        end

        def affected_rows_result(result)
          result.number_of_records_updated || 0
        end

        def last_id_result(result)
          fields = result.generated_fields || []
          field = fields.last
          return unless field
          field.long_value || field.string_value || field.double_value
        end

      end
    end
  end
end
