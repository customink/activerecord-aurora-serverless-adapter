require 'test_helper'

class Activerecord::Aurora::Serverless::BaseTest < Minitest::Spec
  it "has a working client via real aurora serverless cluster" do
    result = execute('SELECT 1 as one')
    expect(result.records.length).must_equal 1
    expect(result.records.first.first.long_value).must_equal 1
  end

  private

  def client
    @client ||= Aws::RDSDataService::Client.new
  end

  def execute(sql)
    client.execute_statement({
      sql: sql,
      database: 'aasa_aurora',
      secret_arn: ENV['AASA_SECRET_ARN'],
      resource_arn: ENV['AASA_RESOURCE_ARN']
    })
  end
end
