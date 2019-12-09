// Thanks to https://almirzulic.com/posts/create-serverless-aurora-cluster-with-cdk/

import { CfnOutput, Construct, Stack, StackProps } from "@aws-cdk/core";
import { Vpc, SubnetType } from "@aws-cdk/aws-ec2";
import { CfnDBCluster, CfnDBSubnetGroup } from "@aws-cdk/aws-rds";
import { CfnSecret } from "@aws-cdk/aws-secretsmanager";
import { User, Policy, PolicyStatement, CfnAccessKey } from "@aws-cdk/aws-iam";

const MASTER_USER = process.env.AASA_MASTER_USER;
const MASTER_PASS = process.env.AASA_MASTER_PASS;
const DATABASE_NAME = "aasa_aurora";

export class AuroraServerlessStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);
    // create vpc
    const vpc = new Vpc(this, "Vpc", {
      cidr: "10.0.0.0/16",
      natGateways: 0,
      subnetConfiguration: [
        { name: "aasa_isolated", subnetType: SubnetType.ISOLATED }
      ]
    });
    new CfnOutput(this, "AASAVpcDefaultSecurityGroup", {
      value: vpc.vpcDefaultSecurityGroup
    });
    // get subnetids from vpc
    const subnetIds: string[] = [];
    vpc.isolatedSubnets.forEach(subnet => {
      subnetIds.push(subnet.subnetId);
    });
    new CfnOutput(this, "AASAVpcSubnetIds", {
      value: JSON.stringify(subnetIds)
    });
    // create subnetgroup
    const dbSubnetGroup: CfnDBSubnetGroup = new CfnDBSubnetGroup(
      this,
      "AuroraSubnetGroup",
      {
        dbSubnetGroupDescription: "Subnet group to AASA Aurora",
        dbSubnetGroupName: "aasa-subnet-group",
        subnetIds
      }
    );
    // create aurora db serverless cluster
    const aurora = new CfnDBCluster(this, "AuroraServerless", {
      databaseName: DATABASE_NAME,
      dbClusterIdentifier: "aasa-aurora",
      engine: "aurora",
      engineMode: "serverless",
      masterUsername: MASTER_USER,
      masterUserPassword: MASTER_PASS,
      // TODO: Uncomment Once Merged: https://github.com/aws/aws-cdk/issues/5216
      // (see alos bin/_deploy-aurora)
      // enableHttpEndpoint: true,
      port: 3306,
      dbSubnetGroupName: dbSubnetGroup.dbSubnetGroupName,
      scalingConfiguration: {
        autoPause: true,
        minCapacity: 1,
        maxCapacity: 16,
        secondsUntilAutoPause: 3600
      }
    });
    aurora.addDependsOn(dbSubnetGroup);
    new CfnOutput(this, "AASAAuroraClusterArn", {
      value: `arn:aws:rds:${this.region}:${this.account}:cluster:${aurora.dbClusterIdentifier}`
    });
    // secrets
    const secret = new CfnSecret(this, "Secret", {
      secretString: JSON.stringify({
        username: MASTER_USER,
        password: MASTER_PASS,
        engine: "mysql",
        host: aurora.attrEndpointAddress,
        port: aurora.attrEndpointPort,
        dbClusterIdentifier: DATABASE_NAME
      }),
      description: "The aasa-aurora cluster master credentials."
    });
    secret.addDependsOn(aurora);
    new CfnOutput(this, "AASASecretArn", {
      value: secret.ref
    });
    // test user
    const user = new User(this, "TestUser");
    const policy = new Policy(this, "TestUserPolicy", {
      statements: [
        new PolicyStatement({
          actions: ["rds-data:*"],
          resources: [
            `arn:aws:rds:${this.region}:${this.account}:cluster:${aurora.dbClusterIdentifier}*`
          ]
        }),
        new PolicyStatement({
          actions: ["secretsmanager:*"],
          resources: [`${secret.ref}*`]
        })
      ]
    });
    user.attachInlinePolicy(policy);
    const key = new CfnAccessKey(this, "TestUserKey", {
      userName: user.userName
    });
    new CfnOutput(this, "AASATestUserAccessKeyId", {
      value: key.ref
    });
    new CfnOutput(this, "AASATestUserSecretAccessKey", {
      value: key.attrSecretAccessKey
    });
  }
}
