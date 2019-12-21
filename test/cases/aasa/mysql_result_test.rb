require 'aasa_helper'

module ActiveRecord
  module ConnectionAdapters
    module AuroraServerless
      class ResultTest < TestCase

        it '#each' do
          execute "DELETE FROM aurora_test"
          execute "INSERT INTO aurora_test (int_test, bit_test) VALUES (1, 1)"
          execute "INSERT INTO aurora_test (int_test, bit_test) VALUES (2, 0)"
          execute "INSERT INTO aurora_test (int_test, bit_test) VALUES (3, 1)"
          # Default as: :array.
          result = execute "SELECT int_test, bit_test FROM aurora_test"
          expect(result.each.length).must_equal 3
          result.each do |row|
            expect(row).must_be_instance_of Array
          end
          expect(result.each[0]).must_equal [1, true]
          expect(result.each[1]).must_equal [2, false]
          expect(result.each[2]).must_equal [3, true]
          # Using as: :hash option for columns. Also uses :symbolize_keys too.
          result = execute "SELECT int_test, bit_test FROM aurora_test"
          kwargs = { as: :hash, symbolize_keys: true }
          result.each(**kwargs) do |row|
            expect(row).must_be_instance_of Hash
          end
          expect(result.each(**kwargs)[0]).must_equal({int_test: 1, bit_test: true})
          expect(result.each(**kwargs)[1]).must_equal({int_test: 2, bit_test: false})
          expect(result.each(**kwargs)[2]).must_equal({int_test: 3, bit_test: true})
        end

        it '#fields and #to_a to work' do
          result = execute('SELECT 1 as one')
          assert_equal ['one'], result.fields
          assert_equal [[1]], result.to_a
        end

        it 'multiple values' do
          execute "DELETE FROM aurora_test"
          execute "INSERT INTO aurora_test (int_test, big_int_test) VALUES (1, 11)"
          execute "INSERT INTO aurora_test (int_test, big_int_test) VALUES (2, 22)"
          execute "INSERT INTO aurora_test (int_test, big_int_test) VALUES (3, 33)"
          result = execute('
            SELECT int_test, big_int_test
            FROM aurora_test
            WHERE int_test IS NOT NULL
            OR big_int_test IS NOT NULL
          ')
          assert_equal ['int_test', 'big_int_test'], result.fields
          assert_equal [[1, 11], [2, 22], [3, 33]], result.to_a
        end

        it 'no results' do
          result = execute('SELECT null_test FROM aurora_test WHERE 1 = 2')
          assert_equal ['null_test'], result.fields
          assert_equal [], result.to_a
        end

      end
    end
  end
end
