module ActiveRecord
  module ConnectionHandling

    def aurora_serverless_connection(config)
      client = aurora_serverless_connection_from_config(config)
      ConnectionAdapters::AuroraServerlessAdapter.new(client, logger, nil, config)
    end

    def aurora_serverless_connection_from_config(config)
      options = config.except :adapter, :database, :secret_arn, :resource_arn
      ConnectionAdapters::AuroraServerless::Client.new(
        config[:database],
        config[:resource_arn],
        config[:secret_arn],
        options
      )
    end
    module_function :aurora_serverless_connection_from_config

  end
end
