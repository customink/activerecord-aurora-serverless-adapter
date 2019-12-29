module AASA
  module Mtr

    def retry_foreign_key_checks?
      defined?(::ActiveRecord) && defined?(::ARUnit2Model)
    end

    def retry_foreign_key_checks(count)
      return unless retry_foreign_key_checks?
      reset_foreign_key_check_for_class ActiveRecord::Base, count
      reset_foreign_key_check_for_class ARUnit2Model, count
    end

    def reset_foreign_key_check_for_class(model, count)
      c = model.connection
      return unless c
      v = c.query_value "SELECT @@FOREIGN_KEY_CHECKS"
      puts "[RETRY-FOREIGN_KEY_CHECKS] current: #{v}"
      c.update "SET FOREIGN_KEY_CHECKS = 1"
      sleep(count)
    end

    extend self

  end
end

# Helpful to see test names for us vs dots.
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new()]

# There is something a little with how fixtures & foreign key checks
# are not session based with Aurora Serverless. Makes a little sense but
# even tho each connection (see config.yml) sets this up for us, some
# VERY small percentage of tests will fail. This helps?
#
Minitest::Retry.use! retry_count: 3, verbose: true
Minitest::Retry.on_retry do |klass, test_name, retry_count|
  AASA::Mtr.retry_foreign_key_checks(retry_count)
end
