module ActiveRecord
  module ConnectionAdapters
    module AuroraServerless
      module Abstract

        # AbstractAdapter

        def prepared_statements
          false
        end

        # Database Statements

        def begin_db_transaction
          @connection.begin_db_transaction
        end

        def commit_db_transaction
          @connection.commit_db_transaction
        end

        def exec_rollback_db_transaction
          @connection.exec_rollback_db_transaction
        end

      end
    end
  end
end
