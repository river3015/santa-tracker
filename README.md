# サンタトラッカー

サンタクロースの現在位置をリアルタイムで追跡するデモアプリ

## 概要

このプロジェクトは以下の機能を提供します：
- サンタの位置情報をリアルタイムで表示
- 日本全土でのサンタの移動を追跡
- 位置情報の自動更新（1秒ごと）

## アーキテクチャ

- フロントエンド: AWS Amplify
- バックエンド: AWS Lambda + API Gateway
- データベース: DynamoDB

## デプロイ方法

1. リポジトリのクローン
```bash
git clone https://github.com/river3015/santa-tracker.git
cd santa-tracker
```

2. 環境変数の設定
`terraform.tfvars`ファイルを作成し、以下の内容を設定：
```hcl
github_repository = "https://github.com/yourusername/santa-tracker"
github_access_token = "あなたのGitHubアクセストークン"
```

3. Lambda関数の準備
```bash
zip lambda_function.zip lambda_function.py
```

4. Terraformでインフラをデプロイ
```bash
terraform init
terraform plan
terraform apply
```

5. デプロイの確認
- AWS Amplifyコンソールにアクセスし、アプリケーションのデプロイ状況を確認
- 自動的にデプロイが開始され、完了すると提供されたURLでアプリケーションにアクセス可能

## 環境変数

- `TABLE_NAME`: DynamoDBテーブル名（Lambda関数で使用）
- `SANTA_TRACKER_API_ENDPOINT`: API GatewayのエンドポイントURL（フロントエンド用）

## 技術スタック

- AWS（Amplify, Lambda, API Gateway, DynamoDB）
- Terraform
- JavaScript（Leaflet.js）
- Python

## 注意事項

- AWS Amplifyを使用するため、GitHubリポジトリとアクセストークンが必要です
- デプロイ前に、terraform.tfvarsファイルに適切な値を設定してください
- カスタムドメインの設定はオプションです。必要に応じて設定を変更してください
