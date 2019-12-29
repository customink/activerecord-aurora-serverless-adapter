source "https://rubygems.org"
git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }
gemspec

ENV['RAILS_VERSION'] = '6.0.2.1'

# This allows us to bundle to Rails via Git to get the ActiveRecord test files
# which comes down to a git tag. We can also use the `RAILS_VERSION` env variable
# too as needed for a very specific/tiny version too.
#
version = ENV['RAILS_VERSION'] || begin
  require 'net/http'
  require 'yaml'
  spec = eval(File.read('activerecord-aurora-serverless-adapter.gemspec'))
  ver = spec.dependencies.detect{ |d|d.name == 'activerecord' }.requirement.requirements.first.last.version
  major, minor, tiny, pre = ver.split('.')
  if !pre
    uri = URI.parse "https://rubygems.org/api/v1/versions/activerecord.yaml"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    YAML.load(http.request(Net::HTTP::Get.new(uri.request_uri)).body).select do |data|
      a, b, c = data['number'].split('.')
      !data['prerelease'] && major == a && (minor.nil? || minor == b)
    end.first['number']
  else
    ver
  end
end
gem 'rails', github: "rails/rails", tag: "v#{version}"
