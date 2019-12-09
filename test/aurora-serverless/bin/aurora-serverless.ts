#!/usr/bin/env node
import "source-map-support/register";
import cdk = require("@aws-cdk/core");
import { AuroraServerlessStack } from "../lib/aurora-serverless-stack";

const app = new cdk.App();
new AuroraServerlessStack(app, "AuroraServerlessStack", {
  stackName: "aasa-mysql",
  description:
    "For testing with the customink/activerecord-aurora-serverless-adapter.",
  tags: {
    env: "dev",
    group: "shared",
    application: "activerecord-aurora-serverless-adapter"
  }
});
