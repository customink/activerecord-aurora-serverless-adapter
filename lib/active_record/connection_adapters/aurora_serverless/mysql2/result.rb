# Wraps a `Aws::RDSDataService::Types::ExecuteStatementResponse` response object.
# https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/RDSDataService/Types/ExecuteStatementResponse.html
#
module ActiveRecord
  module ConnectionAdapters
    module AuroraServerless
      module Mysql2
        class Result
          include Enumerable

          attr_reader :response

          def initialize(response)
            @response = response
          end

          def fields
            @fields ||= begin
              md = @response.column_metadata
              md ? md.map(&:label) : []
            end
          end

          def to_a
            as_array
          end

          def each(**kwargs)
            eobj = each_object(kwargs)
            block_given? ? eobj.each { |r| yield(r) } : eobj
          end

          private

          def each_object(**kwargs)
            symbolize_keys = kwargs[:symbolize_keys]
            kwargs[:as] == :hash ? as_hash(symbolize_keys) : as_array
          end

          def as_array
            @as_array ||= (@response.records || []).map do |fields|
              fields.each_with_index.map do |field, index|
                type = @response.column_metadata[index].type_name
                type_cast(field, type)
              end
            end
          end

          def as_hash(symbolize_keys = true)
            @as_hash ||= begin
              h = ActiveRecord::Result.new(fields, as_array).to_a
              symbolize_keys ? h.map { |r| r.symbolize_keys! } : h
            end
          end

          def type_cast(field, type)
            return if field.is_null
            vmeth = VALUE_METHODS[type] || :string_value
            value = field.public_send(vmeth)
            case type
            when 'DECIMAL'   then type_cast_decimal(value)
            when 'DATE'      then type_cast_date(value)
            when 'YEAR'      then type_cast_year(value)
            else
              value
            end
          end

          def type_cast_decimal(v)
            BigDecimal(v)
          end

          def type_cast_date(v)
            Date.parse(v)
          end

          def type_cast_year(v)
            v.to_i
          end

          VALUE_METHODS = {
            'BIT'        => :boolean_value,
            'TINYINT'    => :long_value,
            'SMALLINT'   => :long_value,
            'MEDIUMINT'  => :long_value,
            'INT'        => :long_value,
            'BIGINT'     => :long_value,
            'FLOAT'      => :double_value,
            'DOUBLE'     => :double_value,
            'DECIMAL'    => :string_value,
            'DATE'       => :string_value,
            'DATETIME'   => :string_value,
            'TIMESTAMP'  => :string_value,
            'TIME'       => :string_value,
            'YEAR'       => :string_value,
            'CHAR'       => :string_value,
            'VARCHAR'    => :string_value,
            'BINARY'     => :blob_value,
            'VARBINARY'  => :blob_value,
            'TINYBLOB'   => :blob_value,
            'TINYTEXT'   => :string_value,
            'BLOB'       => :blob_value,
            'TEXT'       => :string_value,
            'MEDIUMBLOB' => :blob_value,
            'MEDIUMTEXT' => :string_value,
            'LONGBLOB'   => :blob_value,
            'LONGTEXT'   => :string_value,
          }.freeze
          private_constant :VALUE_METHODS

        end
      end
    end
  end
end

