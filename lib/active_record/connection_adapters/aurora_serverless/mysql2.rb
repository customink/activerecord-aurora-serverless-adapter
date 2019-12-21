require 'active_record/connection_adapters/aurora_serverless/mysql2/client'
require 'active_record/connection_adapters/aurora_serverless/mysql2/result'
require 'active_record/connection_adapters/aurora_serverless/mysql2/connection_handling'
require 'active_record/connection_adapters/aurora_serverless/gem_hack'
require 'active_record/connection_adapters/mysql2_adapter'

module ActiveRecord
  module ConnectionAdapters
    class AuroraServerlessAdapter < Mysql2Adapter
      include AuroraServerless::Abstract

    end
  end
end
