require 'active_record'
require 'aws-sdk-rdsdataservice'
require 'active_record/connection_adapters/aurora_serverless/version'
require 'active_record/connection_adapters/aurora_serverless/client'
require 'active_record/connection_adapters/aurora_serverless/abstract'
# TODO: [PG] Make this a conditional require? Railtie config? Just do both?
require 'active_record/connection_adapters/aurora_serverless/mysql2'
