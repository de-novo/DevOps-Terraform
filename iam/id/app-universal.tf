resource "aws_iam_policy" "app_universal" {
  name        = "app-universal"
  path        = "/"
  description = "app-universal"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAnsibleHeadDeployBucketAccess",
      "Action": "s3:ListBucket",
      "Resource": [
        "arn:aws:s3:::hoit-deploy"
      ],
      "Effect": "Allow"
    },
    {
      "Sid": "AllowAnsibleArtifactAccess",
      "Action": "s3:GetObject",
      "Resource": [
        "arn:aws:s3:::hoit-provisioning/ansible",
        "arn:aws:s3:::hoit-provisioning/ansible/*"
      ],
      "Effect": "Allow"
    },
    {
      "Sid": "AllowArtifactsReadAccess",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::hoit-deploy",
        "arn:aws:s3:::hoit-deploy/*"
      ]
    },
    {
      "Sid": "AllowAnsibleCreateDescribeEc2TagsAccess",
      "Action": [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:CreateTags"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
        "Effect": "Allow",
        "Action": [
            "ssm:ResumeSession",
            "ssm:DescribeSessions",
            "ssm:TerminateSession",
            "ssm:StartSession",
            "ssm:ListAssociations",
            "ssm:UpdateInstanceInformation",
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
        ],
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "s3:GetEncryptionConfiguration"
        ],
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "ec2messages:AcknowledgeMessage",
            "ec2messages:DeleteMessage",
            "ec2messages:FailMessage",
            "ec2messages:GetEndpoint",
            "ec2messages:GetMessages",
            "ec2messages:SendReply"
        ],
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds"
        ],
        "Resource": "*"
    }
  ]
}


    EOF
}



output "aws_iam_policy_app_universal_arn" {
  value = aws_iam_policy.app_universal.arn
}
