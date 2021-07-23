resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs_cluster"

  configuration {
    execute_command_configuration {
    logging    = "OVERRIDE"
    log_configuration {

        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_example.name
      }
    }
  }
  setting {
    name = "containerInsights"
    value = "enabled"
  }

  depends_on = [aws_cloudwatch_log_group.ecs_example]
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  container_definitions = jsonencode([{
     name = "sample-app",
     image = "deepakdehradun/python-image",
     essential = true,
     portMappings = [{
          protocol = "tcp"
          containerPort = 2000
          hostPort = 2000
       }]
    }])
  //container_definitions = file("${path.module}/container_definitions.json")
  family = "firsttaskdefinition"
  execution_role_arn = aws_iam_role.my_cutsomizable_container_role.arn
  requires_compatibilities = ["FARGATE"]
  depends_on = [aws_iam_role.my_cutsomizable_container_role]
  memory = 512
  network_mode = "awsvpc"
  cpu = "256"

}

resource "aws_cloudwatch_log_group" "ecs_example" {
  name = "ecs_loggroup"
}

resource "aws_ecs_service" "ecs_service" {
  name            = "firstservice"
  cluster         = aws_ecs_cluster.ecs_cluster.arn
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 1
  network_configuration {
    subnets = ["subnet-7a369811"]
    assign_public_ip = true
    security_groups = ["sg-058d091c8680a240b"]
  }
  launch_type = "FARGATE"
  depends_on = [aws_ecs_cluster.ecs_cluster,aws_ecs_task_definition.ecs_task_definition]

}