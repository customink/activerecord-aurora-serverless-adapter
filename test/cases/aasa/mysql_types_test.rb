require 'aasa_helper'

module ActiveRecord
  module ConnectionAdapters
    module AuroraServerless
      class TypesTest < TestCase

        it 'null_test' do
          expect(value('null_test')).must_be_nil
        end

        it 'bit_test' do
          expect(value('bit_test')).must_equal true
        end

        it 'tiny_int_test' do
          expect(value('tiny_int_test')).must_equal 5
        end

        it 'small_int_test' do
          expect(value('small_int_test')).must_equal 32766
        end

        it 'medium_int_test' do
          expect(value('medium_int_test')).must_equal 8388606
        end

        it 'int_test' do
          expect(value('int_test')).must_equal 2147483646
        end

        it 'big_int_test' do
          expect(value('big_int_test')).must_equal 9223372036854775806
        end

        it 'float_test' do
          expect(value('float_test')).must_equal 156.684
        end

        it 'float_zero_test' do
          expect(value('float_zero_test')).must_equal 0.0
        end

        it 'double_test' do
          expect(value('double_test')).must_equal 606682.888
        end

        it 'decimal_test' do
          expect(value('decimal_test')).must_equal BigDecimal.new('676254.545')
        end

        it 'date_test' do
          expect(value('date_test')).must_be_instance_of Date
          expect(value('date_test').strftime("%Y-%m-%d")).must_equal '2010-04-04'
        end

        it 'date_time_test' do
          expect(value('date_time_test')).must_be_instance_of String
          expect(value('date_time_test')).must_equal '2010-04-04 11:44:00'
        end

        it 'timestamp_test' do
          expect(value('timestamp_test')).must_be_instance_of String
          expect(value('timestamp_test')).must_equal '2010-04-04 11:44:00'
        end

        it 'time_test' do
          expect(value('time_test')).must_be_instance_of String
          expect(value('time_test')).must_equal '11:44:00'
        end

        it 'year_test' do
          expect(value('year_test')).must_equal 2019
        end

        it 'char_test' do
          expect(value('char_test')).must_equal 'abcdefg'
        end

        it 'varchar_test' do
          expect(value('varchar_test')).must_equal 'abcdefg'
        end

        it 'binary_test' do
          expect(value('binary_test')).must_equal "abcdefg#{"\000" * 3}"
          expect(value('binary_test').encoding).must_equal Encoding::ASCII_8BIT
        end

        it 'varbinary_test' do
          expect(value('varbinary_test')).must_equal "abcdefg"
          expect(value('varbinary_test').encoding).must_equal Encoding::ASCII_8BIT
        end

        it 'tiny_blob_test' do
          expect(value('tiny_blob_test')).must_equal "abcdefg"
          expect(value('tiny_blob_test').encoding).must_equal Encoding::ASCII_8BIT
        end

        it 'tiny_text_test' do
          expect(value('tiny_text_test')).must_equal "abcdefg"
        end

        it 'blob_test' do
          expect(value('blob_test')).must_equal "abcdefg"
          expect(value('blob_test').encoding).must_equal Encoding::ASCII_8BIT
        end

        it 'text_test' do
          expect(value('text_test')).must_equal "abcdefg"
        end

        it 'medium_blob_test' do
          expect(value('medium_blob_test')).must_equal "abcdefg"
          expect(value('medium_blob_test').encoding).must_equal Encoding::ASCII_8BIT
        end

        it 'long_blob_test' do
          expect(value('long_blob_test')).must_equal "abcdefg"
          expect(value('long_blob_test').encoding).must_equal Encoding::ASCII_8BIT
        end

        it 'long_text_test' do
          expect(value('long_text_test')).must_equal "abcdefg"
        end

        private

        def value(column)
          @value ||= execute("SELECT #{column} FROM aurora_test LIMIT 1").to_a.first.first
        end

      end
    end
  end
end
