# Keep `AuroraServerless::Client` abstract and mix these methods
# in specifically to mimic the Mysql2 gem's interfaces.
#
module ActiveRecord
  module ConnectionAdapters
    module AuroraServerless
      module Mysql2
        module Client

          def self.default_query_options
            {}
          end

          def query_options
            {}
          end

          def query(sql)
            AuroraServerless::Mysql2::Result.new execute_statement(sql)
          end

          def server_info
            @server_info || begin
              r = query 'SHOW VARIABLES LIKE "version"'
              version = r.to_a.detect{ |r| r.detect { |v| v == 'version' } }.last
              { version: version }
            end
          end

          def close
            nil
          end

          def automatic_close=(*)
            nil
          end

          def escape(string)
            string.
              gsub("'", "\\\\'").
              gsub('"', '\\\"').
              gsub("\0", '\\\0')
          end

          def ping
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
