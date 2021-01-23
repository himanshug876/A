provider "aws" {
  region     = "us-east-2"
}
resource "aws_instance" "web-node" {
  ami           = "ami-0dd9f0e7df0f0a138"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.securitygroups.name}"]
  iam_instance_profile = "${aws_iam_instance_profile.ec2-role.name}"
  tags = {
    Name = "Node1"
}
}
resource "aws_s3_bucket" "bigbasketbucket" {
  bucket = "bigbasketbucket"
  acl    = "private"

  tags = {
    Name        = "testBucket"
  }
}


resource "aws_security_group" "securitygroups" {
  name        = "securitygroups"
  description = "Allow Inbound and outbound traffic"
  vpc_id      = "vpc-c745c0ac"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }
  egress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

}

resource "aws_iam_role" "ec2-role" {
  name = "ec2-role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_instance_profile" "ec2-role" {
  name = "ec2-role"
  role = "${aws_iam_role.ec2-role.name}"
}

resource "aws_iam_role_policy" "ec2-policy" {
  name = "ec2-policy"
  role = "${aws_iam_role.ec2-role.id}"

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
     "Resource": [
        "arn:aws:s3:::bigbasketbucket"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
         "arn:aws:s3:::bigbasketbucket/*"
      ]
    }
  ]
}
EOF
}
