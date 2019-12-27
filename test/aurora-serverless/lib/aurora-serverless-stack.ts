// Thanks to https://almirzulic.com/posts/create-serverless-aurora-cluster-with-cdk/

import { CfnOutput, Construct, Stack, StackProps } from "@aws-cdk/core";
import { Vpc, SubnetType } from "@aws-cdk/aws-ec2";
import {
  CfnDBCluster,
  CfnDBSubnetGroup,
  CfnDBClusterProps,
  CfnDBClusterParameterGroup
} from "@aws-cdk/aws-rds";
import { CfnSecret, CfnSecretProps } from "@aws-cdk/aws-secretsmanager";
import { User, Policy, PolicyStatement, CfnAccessKey } from "@aws-cdk/aws-iam";

const MASTER_USER = process.env.AASA_MASTER_USER;
const MASTER_PASS = process.env.AASA_MASTER_PASS;
const DB_NAME = "activerecord_unittest";
const DB_CLUSTER_ID = "aasa-mysql-unit";

function auroraProps(
  dbName: string,
  dbClusterId: string,
  dbSubnetGroupName: string | undefined,
  dbParamGroup: CfnDBClusterParameterGroup
) {
  return {
    databaseName: dbName,
    dbClusterIdentifier: dbClusterId,
    engine: "aurora",
    engineMode: "serverless",
    masterUsername: MASTER_USER,
    masterUserPassword: MASTER_PASS,
    enableHttpEndpoint: true,
    port: 3306,
    dbSubnetGroupName: dbSubnetGroupName,
    dbClusterParameterGroupName: dbParamGroup.ref,
    scalingConfiguration: {
      autoPause: true,
      minCapacity: 1,
      maxCapacity: 4,
      secondsUntilAutoPause: 3600
    }
  } as CfnDBClusterProps;
}

function secretProps(aurora: CfnDBCluster, dbClusterId: string) {
  return {
    secretString: JSON.stringify({
      username: MASTER_USER,
      password: MASTER_PASS,
      engine: "mysql",
      host: aurora.attrEndpointAddress,
      port: aurora.attrEndpointPort,
      dbClusterIdentifier: dbClusterId
    }),
    description: "AASA Master Credentials."
  } as CfnSecretProps;
}

export class AuroraServerlessStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    // VPC

    const vpc = new Vpc(this, "Vpc", {
      cidr: "10.0.0.0/16",
      natGateways: 0,
      subnetConfiguration: [
        { name: "aasa_isolated", subnetType: SubnetType.ISOLATED }
      ]
    });
    const subnetIds: string[] = [];
    vpc.isolatedSubnets.forEach(subnet => {
      subnetIds.push(subnet.subnetId);
    });

    // SUBNET GROUP

    const dbSubnetGroup: CfnDBSubnetGroup = new CfnDBSubnetGroup(
      this,
      "AuroraSubnetGroup",
      {
        dbSubnetGroupDescription: "Subnet group to AASA Aurora",
        dbSubnetGroupName: "aasa-subnet-group",
        subnetIds
      }
    );

    // RDS PARAMETER GROUP

    const dbParamGroup = new CfnDBClusterParameterGroup(
      this,
      "ParameterGroup",
      {
        family: "aurora5.6",
        description: "Test customink/activerecord-aurora-serverless-adapter.",
        parameters: {
          innodb_large_prefix: "1",
          innodb_file_per_table: "1",
          innodb_file_format: "Barracuda",
          character_set_client: "utf8mb4",
          character_set_connection: "utf8mb4",
          character_set_database: "utf8mb4",
          character_set_results: "utf8mb4",
          character_set_server: "utf8mb4",
          collation_server: "utf8mb4_unicode_ci",
          collation_connection: "utf8mb4_unicode_ci"
        }
      }
    );
    dbParamGroup.addDependsOn(dbSubnetGroup);

    // AURORA SERVERLESS CLUSTERS

    const aurora = new CfnDBCluster(
      this,
      "AuroraServerless",
      auroraProps(
        DB_NAME,
        DB_CLUSTER_ID,
        dbSubnetGroup.dbSubnetGroupName,
        dbParamGroup
      )
    );
    const aurora2 = new CfnDBCluster(
      this,
      "AuroraServerless2",
      auroraProps(
        `${DB_NAME}2`,
        `${DB_CLUSTER_ID}2`,
        dbSubnetGroup.dbSubnetGroupName,
        dbParamGroup
      )
    );
    aurora.addDependsOn(dbParamGroup);
    aurora2.addDependsOn(dbParamGroup);
    new CfnOutput(this, "AASAResourceArn", {
      value: `arn:aws:rds:${this.region}:${this.account}:cluster:${DB_CLUSTER_ID}`
    });
    new CfnOutput(this, "AASAResourceArn2", {
      value: `arn:aws:rds:${this.region}:${this.account}:cluster:${DB_CLUSTER_ID}2`
    });

    // SECRETS

    const secret = new CfnSecret(
      this,
      "Secret",
      secretProps(aurora, DB_CLUSTER_ID)
    );
    const secret2 = new CfnSecret(
      this,
      "Secret2",
      secretProps(aurora2, `${DB_CLUSTER_ID}2`)
    );
    secret.addDependsOn(aurora);
    secret2.addDependsOn(aurora2);
    new CfnOutput(this, "AASASecretArn", {
      value: secret.ref
    });
    new CfnOutput(this, "AASASecretArn2", {
      value: secret2.ref
    });

    // TEST USER

    const user = new User(this, "TestUser");
    const policy = new Policy(this, "TestUserPolicy", {
      statements: [
        new PolicyStatement({
          actions: ["rds-data:*"],
          resources: [
            `arn:aws:rds:${this.region}:${this.account}:cluster:${DB_CLUSTER_ID}*`,
            `arn:aws:rds:${this.region}:${this.account}:cluster:${DB_CLUSTER_ID}2*`
          ]
        }),
        new PolicyStatement({
          actions: ["secretsmanager:*"],
          resources: [`${secret.ref}*`, `${secret2.ref}*`]
        })
      ]
    });
    user.attachInlinePolicy(policy);
    const key = new CfnAccessKey(this, "TestUserKey", {
      userName: user.userName
    });
    new CfnOutput(this, "AASAUserAccessKeyId", {
      value: key.ref
    });
    new CfnOutput(this, "AASAUserSecretAccessKey", {
      value: key.attrSecretAccessKey
    });
  }
}
