# サンタトラッカー

サンタクロースの現在位置をリアルタイムで追跡するジョークアプリ

## 概要

このプロジェクトは以下の機能を提供します：
- サンタの位置情報をリアルタイムで表示
- 日本全土でのサンタの移動を追跡
- 位置情報の自動更新（2秒ごと）

## アーキテクチャ

- フロントエンド: AWS Amplify
- バックエンド: API Gateway + Lambda(Python)
- データベース: DynamoDB

## デプロイ方法

### 1. リポジトリのクローン
```bash
git clone https://github.com/river3015/santa-tracker.git
```

### 2. 環境変数の設定
```bash
cd santa-tracker/terraform
mv terraform.tfvars.original terraform.tfvars
```

下記の変数をあなたの環境に合わせて設定してください。
このリポジトリにpushすると、Amplifyにデプロイされます。
```bash
github_repository = "https://github.com/yourusername/santa-tracker"
github_access_token = "あなたのGitHubアクセストークン"
domain_name = "yourdomainname.com" # お名前.comなどでドメイン名を取得し、ここに設定
```

#### GitHubアクセストークンの取得方法
1. GitHubにログインし、右上のプロフィールアイコン → Settingsをクリック
2. 左サイドバーの一番下にあるDeveloper settingsをクリック
3. Personal access tokens → Tokens (classic)をクリック
4. Generate new tokenをクリック
5. 以下の権限（スコープ）を設定：
repo (すべてのリポジトリアクセス)
admin:repo_hook (webhookの設定用)

### 3. Lambda関数の準備
```bash
cd ..
zip lambda_function.zip lambda_function.py
```

### 4. Terraformでインフラをデプロイ
```bash
terraform init
terraform plan
terraform apply
```

```
 Error: waiting for Amplify Domain Association (d1nik428bhtcoq/santa-tracker-test.com) verification: timeout while waiting for state to become 'PENDING_DEPLOYMENT, AVAILABLE' (last state: 'PENDING_VERIFICATION', timeout: 15m0s)
│
│   with aws_amplify_domain_association.example,
│   on main.tf line 200, in resource "aws_amplify_domain_association" "example":
│  200: resource "aws_amplify_domain_association" "example" {
```
このエラーは正常です。SSL証明書の検証が完了していないためにタイムアウトしました。
以下の手順で解決できます：
1. AmplifyコンソールでDNSレコードを確認
AWSコンソール → Amplify → アプリ選択 → 「ホスティング」→ 「カスタムドメイン」
表示されているDNSレコード（CNAME）の値をコピー

2. お名前.comなどのドメイン管理コンソールで、CNAMEレコードを作成

### 5. デプロイの確認
- AWSコンソールのAmplifyのところで、GitHubアプリのインストールと承認を行なってください。
- 自動的にデプロイが開始され、完了すると提供されたURLでアプリケーションにアクセス可能

## 環境変数

- `TABLE_NAME`: DynamoDBテーブル名（Lambda関数で使用）
- `SANTA_TRACKER_API_ENDPOINT`: API GatewayのエンドポイントURL（フロントエンド用）