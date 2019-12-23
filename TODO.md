
## Stats

```
Finished in 3352.854458s, 2.0069 runs/s, 5.1974 assertions/s.
6729 runs, 17426 assertions, 88 failures, 72 errors, 20 skips
```

* (~70) Misc time preisions errors.
  - TimePrecisionTest#test_formatting_time_according_to_precision
* (11) ActiveRecord::AdapterNotSpecified: The `foo` database is not configured for the `test` environment.
  - ConnectionHandlerTest#test_establish_connection_using_2_level_config_defaults_to_default_env_primary_db:
* (8) Query pattern(s) /BEGIN/i, /COMMIT/i not found.
  - ConcurrentTransactionTest#test_accessing_raw_connection_disables_lazy_transactions
* (4) Cannot add or update a child row: a foreign key constraint fails
  - ConcurrentTransactionTest#test_checking_in_connection_reenables_lazy_transactions
* (26) ArgumentError: invalid configuration option
  - :pool, :prepared_statements, :reaping_frequency, :strict, :flags, advisory_locks
  - PooledConnectionsTest#test_pooled_connection_checkin_two:
  - ActiveRecord::DatabaseTasksDumpSchemaCacheTest#test_dump_schema_cache:

## Continue After Timeout

There is a `continue_after_timeout` setting which the SDK recommends using on DDL statements. Also there is a Mysql2 client method called `#abandon_results!` which is called during batch (maybe other) places.

## Configure Connection

In the `connection_adapters/abstract_mysql_adapter.rb:707` make sure we take a look at things like wait timeout, etc.

## Translate Exceptions

In the `connection_adapters/abstract_mysql_adapter.rb:610` is the MySQL translate exception method. I am sure we are going to have to remap a lot of these.

## Time Zones

I am not sure if our `Mysql2::Result` wrapper should have some zone casting. Will find out as more tests are run, but I had considered using code like this in there.

```ruby
Time.parse(v).utc
utc.parse(v).to_time
utc.parse(v)

def utc
  @utc ||= Time.find_zone('UTC')
end
```

## Prepared Statements

Make sure these are forced to off no matter what. Open the `connection_adapters/mysql2_adapter.rb:41` and consider doing an `initialize` in our adapter before calling `super`.

## Handle DB Warmup Gracefully

Thinking there is a retry in the connection handler and all I got to do is hook up this exception to the translated exception method.

```
Aws::RDSDataService::Errors::BadRequestException (Communications link failure)
Communications link failure (Aws::RDSDataService::Errors::BadRequestException)
The last packet sent successfully to the server was 0 milliseconds ago. The driver has not received any packets from the server.
```

## Connection Pool

Read the SDK docs. Thinking we should only have one or maybe just let the pool work at both the ActiveRecord level and the SDK level? Oh, also... check the HTTP Persistence options too!

