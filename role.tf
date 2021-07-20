resource "aws_iam_policy" "container_policy_ecs" {
  name = "container_policy_ecs"
  description = "the policy to be attached to iam role"
  policy = jsonencode({
    "Version": "2012-10-17",
  "Statement": [
    {
      Effect: "Allow",
      Action: [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource: "*"
    }
  ]
})
}

resource "aws_iam_role" "my_cutsomizable_container_role" {
  name = "my_custom_container_role"
  depends_on = []
  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Principal: {
                "Service":"ecs.amazonaws.com"
            },
            Action: "sts:AssumeRole"
        }
    ]
})
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  policy_arn = aws_iam_policy.container_policy_ecs.arn
  role = aws_iam_role.my_cutsomizable_container_role.name
  depends_on = [aws_iam_policy.container_policy_ecs , aws_iam_role.my_cutsomizable_container_role]
}





