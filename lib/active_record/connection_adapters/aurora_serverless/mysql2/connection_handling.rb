module ActiveRecord
  module ConnectionHandling

    def aurora_serverless_connection(config)
      options = config.except :adapter, :database, :secret_arn, :resource_arn
      client = ConnectionAdapters::AuroraServerless::Client.new(
        config[:database],
        config[:resource_arn],
        config[:secret_arn],
        options
      )
      ConnectionAdapters::AuroraServerlessAdapter.new(client, logger, nil, config)
    end

  end
end
