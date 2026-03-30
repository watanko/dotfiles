---
description: プロジェクトのドキュメントを自動生成する。README.mdとdocs/配下のドキュメント一式を作成・更新する。/doc-format で手動実行。
allowed-tools: Bash(git *), Bash(uv *), Bash(python *), Bash(ls *), Bash(mkdir *), Read, Write, Edit, Glob, Grep, Agent
argument-hint: "[target: all|readme|api|db|infra|diagrams]"
---

# doc-format: プロジェクトドキュメント生成スキル

プロジェクトのコードベースを解析し、以下のドキュメントを日本語で生成・更新します。

## 生成対象

### 1. README.md（プロジェクトルート）

以下のセクションを含むREADMEを生成する:

```markdown
# プロジェクト名

## 概要
（プロジェクトの目的と主要機能を簡潔に説明）

## 環境構築

### 前提条件
（必要なツール・ランタイムとバージョン）

### セットアップ手順
（clone〜起動までをステップバイステップで記載。コマンドはコードブロックで示す）

### 環境変数
（必要な環境変数を表形式で記載。.env.exampleがあれば参照する）

## 使い方

### 起動方法
（開発サーバー起動、ビルド、テスト実行などの基本コマンド）

### 使用例
（主要な操作フローをステップバイステップで記載。curlやスクリーンショットを交えて具体的に）

## ドキュメント
詳細なドキュメントは [docs/](./docs/) を参照してください。

| ドキュメント | 説明 |
|---|---|
| [APIエンドポイント](./docs/api-endpoints.md) | REST API仕様 |
| [データベース構造](./docs/db-structure.md) | テーブル定義・ER図 |
| [インフラ構成](./docs/infra-architecture.md) | インフラ構成と設計方針 |
| [構成図](./docs/diagrams/) | インフラ構成図（画像） |
```

### 2. docs/api-endpoints.md

コードベースからAPIエンドポイントを検出し、以下の形式で記載する:

- エンドポイント一覧（メソッド、パス、説明の表）
- 各エンドポイントの詳細:
  - リクエスト（パラメータ、ボディのスキーマ）
  - レスポンス（ステータスコード、ボディのスキーマ）
  - 使用例（curlコマンド）

検出対象: FastAPI/Django/Flask/Express等のルーティング定義、OpenAPI specがあればそれも参照する。

### 3. docs/db-structure.md

コードベースからデータベース構造を検出し、以下の形式で記載する:

- テーブル一覧（テーブル名、説明の表）
- 各テーブルの詳細:
  - カラム定義（名前、型、制約、説明の表）
  - インデックス
  - リレーション
- ER図（Mermaid記法でMarkdown内に記載）

検出対象: SQLAlchemy/Django ORM/Prisma/マイグレーションファイル等のモデル定義。

### 4. docs/infra-architecture.md

コードベースからインフラ構成を検出し、以下の形式で記載する:

- 全体構成の概要
- 各コンポーネントの説明（サービス名、役割、設定の要点）
- ネットワーク構成
- デプロイフロー
- 構成図は docs/diagrams/ の画像を参照する

検出対象: docker-compose.yml, Dockerfile, Terraform, CDK, CloudFormation, Kubernetes manifests, CI/CD設定ファイル等。

### 5. docs/diagrams/

Pythonの `diagrams` ライブラリ（https://diagrams.mingrammer.com/）を使ってインフラ構成図を画像として生成する:

- `diagrams` がインストールされていない場合は `uv add --dev diagrams` で追加する
- `graphviz` が必要。未インストールなら `sudo apt-get install -y graphviz` を実行する（ユーザーに確認を取ること）
- docs/diagrams/ 配下にPythonスクリプトを生成し、実行して画像を出力する
- 生成する図:
  - `infra_overview.py` → `infra_overview.png` — 全体インフラ構成図
  - `network_diagram.py` → `network_diagram.png` — ネットワーク構成図（該当する場合）
- 画像生成後、docs/infra-architecture.md から `![全体構成図](./diagrams/infra_overview.png)` のように参照する

#### diagrams ライブラリの使い方

```python
from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import ECS, Lambda
from diagrams.aws.database import RDS, ElastiCache
from diagrams.aws.network import ELB, CloudFront, Route53
from diagrams.onprem.client import Users
# ... 他のノードは https://diagrams.mingrammer.com/docs/nodes/onprem 等を参照

with Diagram("インフラ全体構成", filename="docs/diagrams/infra_overview", show=False, direction="LR"):
    users = Users("ユーザー")

    with Cluster("AWS"):
        lb = ELB("ALB")
        with Cluster("ECS Cluster"):
            app = ECS("App")
        db = RDS("PostgreSQL")
        cache = ElastiCache("Redis")

    users >> lb >> app
    app >> db
    app >> cache
```

#### 重要な注意点
- `filename` にはパスを指定する（拡張子不要、自動で `.png` が付く）
- `show=False` を必ず指定する（ブラウザを開かない）
- Cluster でグルーピングを表現する
- AWS/GCP/Azure/オンプレなど、検出されたインフラに応じた適切なノードを使う
- Docker Composeのみの構成なら `diagrams.onprem` のノードを使う:
  - `diagrams.onprem.compute.Docker`
  - `diagrams.onprem.database.PostgreSQL`
  - `diagrams.onprem.inmemory.Redis`
  - `diagrams.onprem.network.Nginx`
  - 等
- スクリプトは `python docs/diagrams/infra_overview.py` で実行する

## 実行手順

1. プロジェクト構造を把握する（ファイル構成、使用フレームワーク、設定ファイル）
2. `$ARGUMENTS` に応じて生成対象を決定する:
   - `all` または引数なし: 全ドキュメント生成
   - `readme`: README.mdのみ
   - `api`: docs/api-endpoints.mdのみ
   - `db`: docs/db-structure.mdのみ
   - `infra`: docs/infra-architecture.mdのみ
   - `diagrams`: docs/diagrams/のみ
3. コードベースを解析して情報を収集する
4. `docs/` ディレクトリを作成する（存在しない場合）
5. 各ドキュメントを生成・更新する
6. diagrams生成時はPythonスクリプトを生成し `python` で実行して画像をレンダリングする

## 対象プロジェクト情報

!`ls -la`

### パッケージ設定

!`cat pyproject.toml 2>/dev/null || cat package.json 2>/dev/null || echo "No package config found"`

### Docker構成

!`cat docker-compose.yml 2>/dev/null || cat docker-compose.yaml 2>/dev/null || echo "No docker-compose found"`

### 既存ドキュメント

!`ls docs/ 2>/dev/null || echo "No docs directory"`

## 注意事項

- すべてのドキュメントは **日本語** で記述する
- コード例やコマンドはそのまま英語で記載する
- 既存のドキュメントがある場合は上書きではなく内容をマージ・更新する
- 推測で情報を書かない。コードから読み取れる事実のみを記載する
- diagrams画像のレンダリングに失敗した場合はPythonスクリプトのみ残す（手動実行可能）
