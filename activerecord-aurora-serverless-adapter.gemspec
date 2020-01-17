lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "active_record/connection_adapters/aurora_serverless/version"

Gem::Specification.new do |spec|
  spec.name          = "activerecord-aurora-serverless-adapter"
  spec.version       = ActiveRecord::ConnectionAdapters::AuroraServerless::VERSION
  spec.authors       = ["Ken Collins"]
  spec.email         = ["kcollins@customink.com"]
  spec.summary       = %q{ActiveRecord Adapter for Amazon Aurora Serverless}
  spec.description   = %q{Amazon Aurora Serverless is an on-demand, auto-scaling configuration for Amazon Aurora (MySQL-compatible and PostgreSQL-compatible editions). Perfect for small Rails on AWS Lambda.}
  spec.homepage      = 'https://github.com/customink/activerecord-aurora-serverless-adapter'
  spec.license       = 'MIT'
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features|docker)/i})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_runtime_dependency     'activerecord', '>= 6.0'
  spec.add_runtime_dependency     'aws-sdk-rdsdataservice'
  spec.add_runtime_dependency     'retriable'
  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'minitest-retry'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'sqlite3'
end
