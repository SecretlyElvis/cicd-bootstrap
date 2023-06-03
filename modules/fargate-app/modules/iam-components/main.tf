#########################################################
## IAM User for Jenkins Master (Slave Standup Privileges)
resource "aws_iam_user" "jenkins-master-user" {
  name = join("_", [ var.basename, "jenkins", "aws", var.stack_env, "agent" ])
  force_destroy = true

  tags = merge(
      tomap({
              "Name" = join("_", [ var.basename, "jenkins", "aws", var.stack_env, "agent" ])
          }),
      var.common_tags
  ) 
}

resource "aws_iam_user_policy" "jenkins-master-policy" {
  name   = join("-", [ var.basename, "jenkins", "master", "policy" ])

  user   = aws_iam_user.jenkins-master-user.name
  policy = file("${path.root}${var.jenkins_master_policy}")
}

######################################################
## IAM User For Jenkins Slave (Assume Role Privileges)
resource "aws_iam_user" "jenkins-slave-user" {
  name = join("_", [ var.basename, "jenkins", "aws", var.stack_env, "deploy" ])
  force_destroy = true

  tags = merge(
      tomap({
              "Name" = join("_", [ var.basename, "jenkins", "aws", var.stack_env, "deploy" ])
          }),
      var.common_tags
  ) 
}

data "aws_iam_policy_document" "jenkins-slave-policy-data" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = setunion( [ "${aws_iam_role.cicd-account-assumable-role.arn}" ], 
                            var.assumable_roles )
  }
}

resource "aws_iam_user_policy" "jenkins-slave-policy" {
  name   = join("-", [ var.basename, "jenkins", "slave", "policy" ])

  user   = aws_iam_user.jenkins-slave-user.name
  policy = data.aws_iam_policy_document.jenkins-slave-policy-data.json
}

########################
## Sample Assumable Role
resource "aws_iam_role" "cicd-account-assumable-role" {
  name = join("_", [ var.basename, "jenkins", var.stack_env, "deployment", "role" ])

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_user.jenkins-slave-user.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = merge(
      tomap({
              "Name" = join("_", [ var.basename, "jenkins", var.stack_env, "deployment", "role" ])
          }),
      var.common_tags
  )   
}

resource "aws_iam_policy" "assumable-role-policy" {
  name = join("_", [ var.basename, "jenkins", var.stack_env, "deployment", "policy" ])

  policy = file("${path.root}${var.deployment_role_policy}")

}

resource "aws_iam_role_policy_attachment" "assumable-role-to-policy-attachment" {
  role       = "${aws_iam_role.cicd-account-assumable-role.name}"
  policy_arn = "${aws_iam_policy.assumable-role-policy.arn}"

}
