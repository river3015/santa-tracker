terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# DynamoDBテーブルの作成
resource "aws_dynamodb_table" "santa_tracker" {
  name         = "SantaTracker"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# IAMロールとポリシーの作成
resource "aws_iam_role" "lambda_role" {
  name = "santa_tracker_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "santa_tracker_lambda_policy"
  description = "Policy for Santa Tracker Lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        Resource = aws_dynamodb_table.santa_tracker.arn
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:ap-northeast-1:*:log-group:/aws/lambda/update_santa_location:*",
          "arn:aws:logs:ap-northeast-1:*:log-group:/aws/lambda/update_santa_location"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda関数の作成
resource "aws_lambda_function" "update_location" {
  function_name = "update_santa_location"
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_role.arn

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  timeout     = 30
  memory_size = 128

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.santa_tracker.name
    }
  }
}

# Lambda関数のCloudWatch Logs用のロググループを明示的に作成
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/update_santa_location"
  retention_in_days = 14
}

# API Gatewayの作成
resource "aws_apigatewayv2_api" "santa_api" {
  name          = "SantaAPI"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.santa_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.update_location.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.santa_api.id
  route_key = "GET /santa"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.santa_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_location.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.santa_api.execution_arn}/*/*"
}

# Amplifyアプリケーションの作成
resource "aws_amplify_app" "santa_tracker" {
  name = "santa-tracker"

  # GitHub等のリポジトリ設定
  repository = var.github_repository
  access_token = var.github_access_token  # GitHubアクセストークン

  # ビルド設定
  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        build:
          commands:
            - echo "Building..."
            - echo "window.SANTA_TRACKER_API_ENDPOINT='${aws_apigatewayv2_stage.api_stage.invoke_url}/santa';" > env.js
      artifacts:
        baseDirectory: /
        files:
          - '**/*'
          - env.js
      cache:
        paths: []
  EOT

  # 環境変数
  environment_variables = {
    SANTA_TRACKER_API_ENDPOINT = "${aws_apigatewayv2_stage.api_stage.invoke_url}/santa"
  }

  # カスタムルール
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }
}

# ブランチの設定
resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.santa_tracker.id
  branch_name = "main"

  framework = "None"  # 静的サイトの場合
  stage     = "PRODUCTION"

  environment_variables = {
    ENVIRONMENT = "production"
  }
}

# ドメイン設定（オプション）
resource "aws_amplify_domain_association" "example" {
  app_id      = aws_amplify_app.santa_tracker.id
  domain_name = "santa-tracker.example.com"

  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = ""
  }
}