module ActiveRecord
  module ConnectionAdapters
    module AuroraServerless
      class Client
        attr_reader :database,
                    :resource_arn,
                    :secret_arn,
                    :raw_client,
                    :affected_rows

        def initialize(database, resource_arn, secret_arn, client_options = {})
          @database = database
          @resource_arn = resource_arn
          @secret_arn = secret_arn
          @raw_client = Aws::RDSDataService::Client.new(client_options)
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
            @affected_rows = r.number_of_records_updated
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

      end
    end
  end
end
