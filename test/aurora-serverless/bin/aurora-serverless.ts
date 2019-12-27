#!/usr/bin/env node
import "source-map-support/register";
import cdk = require("@aws-cdk/core");
import { AuroraServerlessStack } from "../lib/aurora-serverless-stack";

const APP = new cdk.App();

new AuroraServerlessStack(APP, "AuroraServerlessStack", {
  stackName: "aasa-mysql-unit",
  description: "Test customink/activerecord-aurora-serverless-adapter.",
  tags: {
    env: "dev",
    group: "shared",
    application: "activerecord-aurora-serverless-adapter",
    owner: "kcollins"
  }
});
