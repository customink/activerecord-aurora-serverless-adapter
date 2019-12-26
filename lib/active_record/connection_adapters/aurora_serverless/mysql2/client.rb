# Keep `AuroraServerless::Client` abstract and mix these methods
# in specifically to mimic the Mysql2 gem's interfaces.
#
module ActiveRecord
  module ConnectionAdapters
    module AuroraServerless
      module Mysql2
        module Client

          ESCAPE_MAP = {
            "\x00" => "0",
            "\n"   => "n",
            "\r"   => "r",
            "\\"   => "\\",
            "'"    => "'",
            '"'    => '"'
          }.freeze

          ESCAPE_PATTERN = Regexp.union(*ESCAPE_MAP.keys)

          def self.default_query_options
            {}
          end

          def query_options
            {}
          end

          def query(sql)
            raise ActiveRecord::StatementInvalid if @closed
            result = execute_statement(sql)
            AuroraServerless::Mysql2::Result.new(result)
          end

          def server_info
            @server_info || begin
              r = query 'SHOW VARIABLES LIKE "version"'
              version = r.to_a.detect{ |r| r.detect { |v| v == 'version' } }.last
              { version: version }
            end
          end

          def close
            @closed = true
          end

          def automatic_close=(*)
            nil
          end

          def escape(string)
            string.gsub(ESCAPE_PATTERN) { |x| "\\#{ESCAPE_MAP[x]}" }
          end

          def ping
            return false if @closed
            query('SELECT 1').to_a.first.first == 1
          rescue
            false
          end

          def abandon_results!
            nil
          end

        end
      end
      AuroraServerless::Client.include AuroraServerless::Mysql2::Client
    end
  end
end
