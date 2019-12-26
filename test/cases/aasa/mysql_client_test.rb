require 'aasa_helper'

module ActiveRecord
  module ConnectionAdapters
    module AuroraServerless
      class ClientTest < TestCase

        it '#server_info' do
          expect(client.server_info).must_equal({
            version: '5.6.10'
          })
        end

        it '#escape' do
          expect(client.escape("\\ \001 ' \n \\n \"")).
            must_equal("\\\\ \u0001 \\' \\n \\\\n \\\"")
          expect(client.escape("abc'def\"ghi\0jkl%mno")).
            must_equal("abc\\'def\\\"ghi\\0jkl%mno")
        end

        it '#ping' do
          expect(client.ping).must_equal true
        end

        it 'transactions' do
          begin
            execute "DELETE FROM aurora_test"
            client.begin_db_transaction
            execute "INSERT INTO aurora_test (int_test) VALUES (1)"
            expect(execute("SELECT int_test FROM aurora_test").to_a).must_equal [[1]]
          ensure
            client.exec_rollback_db_transaction
            expect(execute("SELECT int_test FROM aurora_test").to_a).must_equal []
          end
        end

        it '#affected_rows' do
          execute "DELETE FROM aurora_test"
          execute "INSERT INTO aurora_test (int_test) VALUES (1)"
          expect(client.affected_rows).must_equal 1
          execute "SELECT * FROM aurora_test"
          expect(client.affected_rows).must_equal 0
          execute "INSERT INTO aurora_test (int_test) VALUES (1)"
          execute "INSERT INTO aurora_test (int_test) VALUES (1)"
          execute "DELETE FROM aurora_test"
          expect(client.affected_rows).must_equal 3
        end

        it '#last_id' do
          execute "INSERT INTO aurora_test (int_test) VALUES (1)"
          expect(client.last_id).must_equal 2
          execute "INSERT INTO aurora_test (int_test) VALUES (1)"
          expect(client.last_id).must_equal 3
        end

      end
    end
  end
end
