# We need `ActiveRecord::ConnectionHandling::RAILS_ENV.call` to return
# nil just like when running the ActiveRecord suite. This allows the
# `DEFAULT_ENV.call` to return `default_env` propery for a lot fo tests.
#
module Rails
  class << self
    def env
      nil
    end
  end
end
