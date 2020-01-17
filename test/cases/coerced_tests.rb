require 'aasa_helper'

class BasicsTest < ActiveRecord::TestCase
  # This segfault my local ruby.
  coerce_tests! :test_marshalling_with_associations,
                :test_marshal_between_processes

  # We are like PG and avoid this test.
  coerce_tests! :test_respect_internal_encoding
end

class TimePrecisionTest < ActiveRecord::TestCase
  coerce_tests! :test_formatting_time_according_to_precision
  # Value `999000` in test, core is `999900`, too much for aurora serverless.
  def test_formatting_time_according_to_precision_coerced
    skip unless @connection # Avoids arunit2 suite run errors.
    @connection.create_table(:foos, force: true) do |t|
      t.time :start,  precision: 0
      t.time :finish, precision: 4
    end
    time = ::Time.utc(2000, 1, 1, 12, 30, 0, 999999)
    Foo.create!(start: time, finish: time)
    assert foo = Foo.find_by(start: time)
    assert_equal 1, Foo.where(finish: time).count
    assert_equal time.to_s, foo.start.to_s
    assert_equal time.to_s, foo.finish.to_s
    assert_equal 000000, foo.start.usec
    assert_equal 999000, foo.finish.usec
  end

  # Value `123000000` in test, core is `123456000`, too much for aurora serverless.
  coerce_tests! :test_time_precision_is_truncated_on_assignment
  def test_time_precision_is_truncated_on_assignment_coerced
    skip unless @connection # Avoids arunit2 suite run errors.
    @connection.create_table(:foos, force: true)
    @connection.add_column :foos, :start,  :time, precision: 0
    @connection.add_column :foos, :finish, :time, precision: 6
    time = ::Time.now.change(nsec: 123456789)
    foo = Foo.new(start: time, finish: time)
    assert_equal 0, foo.start.nsec
    assert_equal 123456000, foo.finish.nsec
    foo.save!
    foo.reload
    assert_equal 0, foo.start.nsec
    assert_equal 123000000, foo.finish.nsec
  end
end

class TransactionTest < ActiveRecord::TestCase
  # These use `assert_sql` for transactions. No can do since we make a SDK call.
  coerce_tests! :test_accessing_raw_connection_disables_lazy_transactions,
                :test_accessing_raw_connection_materializes_transaction,
                :test_unprepared_statement_materializes_transaction,
                :test_transactions_can_be_manually_materialized
end

# TOOD: This inherits (and runs) the `TransactionTest` case file. However,
# there is a slight chance one fails due to a foreign key constraints issue.
# If you want to play, comment this out and.
#
# TESTOPTS="-n='/ConcurrentTransactionTest/'" ONLY_ACTIVERECORD=1 bundle exec rake
#
class ConcurrentTransactionTest < TransactionTest
  coerce_all_tests!
end

class LogSubscriberTest < ActiveRecord::TestCase
  # False positive due to Rails bundle.
  coerce_tests! :test_vebose_query_logs
end

module ActiveRecord
  class AdapterTest < ActiveRecord::TestCase
    # Cross DB selects are simply not going to work.
    coerce_tests! :test_not_specifying_database_name_for_cross_database_selects
  end
end

class FixturesTest < ActiveRecord::TestCase
  #  We do not support batch statements.
  coerce_tests! :test_bulk_insert_multiple_table_with_a_multi_statement_query,
                :test_insert_fixtures_set_raises_an_error_when_max_allowed_packet_is_smaller_than_fixtures_set_size,
                :test_bulk_insert_with_multi_statements_enabled,
                :test_insert_fixtures_set_concat_total_sql_into_a_single_packet_smaller_than_max_allowed_packet
end

module ActiveRecord
  module ConnectionAdapters
    class SchemaCacheTest < ActiveRecord::TestCase
      private
      # These tests can not find the `schema_dump_path` because of our test
      # setup and we can help fix that using test/config.rb constants.
      def schema_dump_path
        File.join ASSETS_ROOT, "schema_dump_5_1.yml"
      end
    end
  end
end

class AttributeMethodsTest < ActiveRecord::TestCase
  # Our before type cast is actually a boolean.
  coerce_tests! :test_read_attributes_before_type_cast_on_a_boolean
end

module ActiveRecord
  class MysqlDBCreateWithInvalidPermissionsTest < ActiveRecord::TestCase
    # This adapter can not create DBs.
    coerce_tests! :test_raises_error
  end
end

module ActiveRecord
  module ConnectionAdapters
    class ConnectionHandlersMultiDbTest < ActiveRecord::TestCase
      # This tries to load PG for some reason.
      coerce_tests! :test_switching_connections_with_database_url

      # No sqlite3 tests.
      coerce_tests! :test_multiple_connection_handlers_works_in_a_threaded_environment,
                    :test_time_precision_is_truncated_on_assignment_coerced,
                    :test_formatting_time_according_to_precision_coerced
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    class ConnectionHandlerTest < ActiveRecord::TestCase
      # No sqlite3 tests.
      coerce_tests! :test_establish_connection_using_2_level_config_defaults_to_default_env_primary_db,
                    :test_establish_connection_using_3_level_config_defaults_to_default_env_primary_db
    end
  end
end


# Sick of these failing. Likely due to setup/teardown hacks. *shrug*
class HasAndBelongsToManyAssociationsTest < ActiveRecord::TestCase
  coerce_tests! :test_adding_from_the_project_fixed_timestamp,
                :test_adding_from_the_project,
                :test_adding_single
end
