module ActiveRecord
  module ConnectionHandling

    def aurora_serverless_connection(config)
      client = aurora_serverless_connection_from_config(config)
      ConnectionAdapters::AuroraServerlessAdapter.new(client, logger, nil, config)
    end

    def aurora_serverless_connection_from_config(config)
      ConnectionAdapters::AuroraServerless::Client.new(
        config[:database],
        config[:resource_arn],
        config[:secret_arn],
        config
      )
    end
    module_function :aurora_serverless_connection_from_config

  end
end
