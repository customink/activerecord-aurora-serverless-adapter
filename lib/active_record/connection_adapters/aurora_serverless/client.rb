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
          @transactions = []
          @affected_rows = 0
          @debug_transactions = false # Development toggle.
        end

        def inspect
          "#<#{self.class} database: #{database.inspect}, raw_client: #{raw_client.inspect}>"
        end

        def execute_statement_retry(sql)
          if @connected
            execute_statement(sql)
          else
            auto_paused_retry { execute_statement(sql) }
          end
        end

        def execute_statement(sql)
          id = @transactions.first
          debug_transactions "EXECUTE: #{sql}", id
          raw_client.execute_statement({
            sql: sql,
            database: database,
            secret_arn: secret_arn,
            resource_arn: resource_arn,
            include_result_metadata: true,
            transaction_id: id
          }).tap do |r|
            @connected = true
            @affected_rows = affected_rows_result(r)
            @last_id = last_id_result(r)
          end
        rescue Exception => e
          if id && e.message == "Transaction #{id} is not found"
            @transactions.shift
            retry
          else
            raise e
          end
        end

        def begin_db_transaction
          id = raw_client.begin_transaction({
            database: database,
            secret_arn: secret_arn,
            resource_arn: resource_arn
          }).try(:transaction_id)
          debug_transactions 'BEGIN', id
          @transactions.unshift(id) if id
          true
        end

        def commit_db_transaction
          id = @transactions.shift
          return unless id
          debug_transactions 'COMMIT', id
          raw_client.commit_transaction({
            secret_arn: secret_arn,
            resource_arn: resource_arn,
            transaction_id: id
          })
          true
        rescue
          @transactions.unshift(id) # For imminent rollback.
        end

        def exec_rollback_db_transaction
          id = @transactions.shift
          return unless id
          debug_transactions 'ROLLBACK', id
          raw_client.rollback_transaction({
            secret_arn: secret_arn,
            resource_arn: resource_arn,
            transaction_id: id
          })
          true
        end

        private

        def client_options(options)
          options.slice(*CLIENT_OPTIONS)
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

        def auto_paused_retry
          error_klass = Aws::RDSDataService::Errors::BadRequestException
          error_msg = /last packet sent successfully to the server was/
          retry_msg = 'Aurora auto paused, retrying...'
          on_retry = Proc.new { sleep(1) ; ::Rails.logger.info(retry_msg)  }
          Retriable.retriable({
            on: { error_klass => error_msg },
            on_retry: on_retry,
            tries: auto_paused_retry_count
          }) { yield }
        end

        def auto_paused_retry_count
          10
        end

        def debug_transactions(name, id = 'NOID')
          return unless @debug_transactions
          ActiveRecord::Base.logger.debug "  \e[36m#{name} #{id} #{object_id}\e[0m"
        end

        # From AWS docs at https://amzn.to/35V6O8L
        CLIENT_OPTIONS = %i[
          credentials
          region
          access_key_id
          active_endpoint_cache
          client_side_monitoring
          client_side_monitoring_client_id
          client_side_monitoring_host
          client_side_monitoring_port
          client_side_monitoring_publisher
          convert_params
          disable_host_prefix_injection
          endpoint
          endpoint_cache_max_entries
          endpoint_cache_max_threads
          endpoint_cache_poll_interval
          endpoint_discovery
          log_formatter
          log_level
          logger
          profile
          retry_base_delay
          retry_jitter
          retry_limit
          retry_max_delay
          secret_access_key
          session_token
          stub_responses
          validate_params
          http_proxy
          http_open_timeout
          http_read_timeout
          http_idle_timeout
          http_continue_timeout
          http_wire_trace
          ssl_verify_peer
          ssl_ca_bundle
          ssl_ca_directory
        ].freeze

      end
    end
  end
end
