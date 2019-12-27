ENV['AASA_ENV'] = 'test'
require 'bundler/setup'
Bundler.require :default, :development
Dotenv.load('.env')
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/retry'
require 'minitest/reporters'
require 'cases/helper' unless ENV['TEST_FILES'] || ENV['ONLY_AASA']
require_relative 'support/aasa_coerceable'
require_relative 'support/aasa_env'
require_relative 'support/aasa_fixtures'
require_relative 'support/aasa_minitest'
Rails.backtrace_cleaner.remove_silencers! if ENV['REMOVE_SILENCERS']

module ActiveRecord
  module ConnectionAdapters
    module AuroraServerless
      class TestCase < Minitest::Spec

        before { setup_table }
        after  { drop_table }

        private

        def client
          @client ||= AuroraServerless::Client.new(
            'activerecord_unittest',
            ENV['AASA_RESOURCE_ARN'],
            ENV['AASA_SECRET_ARN']
          )
        end

        def execute(sql)
          r = client.execute_statement(sql)
          # TODO: [PG] Make this a conditional result wrapper.
          AuroraServerless::Mysql2::Result.new(r)
        end

        def setup_table
          # TODO: [PG] Make this a conditional for constant SQL.
          execute MYSQL_CREATE_TABLE_SQL
          execute MYSQL_INSERT_SQL
        end

        def drop_table
          execute 'DROP TABLE IF EXISTS aurora_test'
        end

        MYSQL_CREATE_TABLE_SQL = %[
          CREATE TABLE IF NOT EXISTS aurora_test (
            id int NOT NULL AUTO_INCREMENT,
            PRIMARY KEY (id),
            null_test VARCHAR(10),
            bit_test BIT,
            tiny_int_test TINYINT,
            small_int_test SMALLINT,
            medium_int_test MEDIUMINT,
            int_test INT,
            big_int_test BIGINT,
            float_test FLOAT(10,3),
            float_zero_test FLOAT(10,3),
            double_test DOUBLE(10,3),
            decimal_test DECIMAL(10,3),
            decimal_zero_test DECIMAL(10,3),
            date_test DATE,
            date_time_test DATETIME,
            timestamp_test TIMESTAMP,
            time_test TIME,
            year_test YEAR(4),
            char_test CHAR(10),
            varchar_test VARCHAR(10),
            binary_test BINARY(10),
            varbinary_test VARBINARY(10),
            tiny_blob_test TINYBLOB,
            tiny_text_test TINYTEXT,
            blob_test BLOB,
            text_test TEXT,
            medium_blob_test MEDIUMBLOB,
            medium_text_test MEDIUMTEXT,
            long_blob_test LONGBLOB,
            long_text_test LONGTEXT,
            enum_test ENUM('val1', 'val2'),
            set_test SET('val1', 'val2')
          ) DEFAULT CHARSET=utf8
        ]

        MYSQL_INSERT_SQL = %[
          INSERT INTO aurora_test (
            null_test,
            bit_test,
            tiny_int_test,
            small_int_test,
            medium_int_test,
            int_test,
            big_int_test,
            float_test,
            float_zero_test,
            double_test,
            decimal_test,
            decimal_zero_test,
            date_test,
            date_time_test,
            timestamp_test,
            time_test,
            year_test,
            char_test,
            varchar_test,
            binary_test,
            varbinary_test,
            tiny_blob_test,
            tiny_text_test,
            blob_test,
            text_test,
            medium_blob_test,
            medium_text_test,
            long_blob_test,
            long_text_test,
            enum_test,
            set_test
          )
          VALUES (
            NULL,
            1,
            5,
            32766,
            8388606,
            2147483646,
            9223372036854775806,
            156.68449197860963,
            0.0,
            606682.8877005348,
            676254.5454545454,
            0,
            '2010-4-4',
            '2010-4-4 11:44:00',
            '2010-4-4 11:44:00',
            '11:44:00',
            2019,
            'abcdefg',
            'abcdefg',
            'abcdefg',
            'abcdefg',
            'abcdefg',
            'abcdefg',
            'abcdefg',
            'abcdefg',
            'abcdefg',
            'abcdefg',
            'abcdefg',
            'abcdefg',
            'val1',
            'val1,val2'
          )
        ]

      end
    end
  end
end
