[![CI Status](https://github.com/customink/activerecord-aurora-serverless-adapter/workflows/CI/badge.svg)](https://launch-editor.github.com/actions?nwo=customink%activerecord-aurora-serverless-adapter&workflowID=CI)

# Activerecord::Aurora::Serverless::Adapter

TODO...

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/customink/activerecord-aurora-serverless-adapter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

### Testing

Cloning the repo and running the tests locally is super easy assuming you have:

1. Docker Installed
2. AWS Account Configured

These commands will use Docker to setup a node runtime leveraging [AWD CDK](https://github.com/aws/aws-cdk) to deploy a Aurora Serverless stack. Note, you may be to use/set `AWS_PROFILE` for the deploy command.

```s
$ ./bin/bootstrap
$ export AASA_MASTER_USER=admin
$ export AASA_MASTER_PASS=supersecret
$ ./test/bin/deploy-aurora
```

The outputs of this deployed stack will containt an `AASASecretArn` and a `AASAAuroraClusterArn` value. Please place these into the local `.env` file in the following format where `{{ VALUE }}` is replaced.

```
AASA_SECRET_ARN={{ VALUE:AASASecretArn }}
AASA_RESOURCE_ARN={{ VALUE:AASAAuroraClusterArn }}
```

Finally, assuming you have your default AWS account setup with full access to your account, now you can run the tests. Again, `AWS_PROFILE` can be used here and set in `.env` file as needed.

```s
$ ./bin/test
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Activerecord::Aurora::Serverless::Adapter project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/customink/activerecord-aurora-serverless-adapter/blob/master/CODE_OF_CONDUCT.md).
