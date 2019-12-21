
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

## Misc ActiveRecord Code/Conditions To Remember

These are things that stuck out to me to circle back to when the full test suite is in better condition.

* `def cacheable_query` - Make sure we are not using prepared statements.
* `def multi_statements_enabled?(flags)` - Not sure if this should be true or false.

