#!/bin/bash
#============================================================
# vc_setup_config.sh
# ─ VC特化版ワークスペース構築スクリプト用のコンフィグファイル
#
# 使い方: cp vc_setup_config.sh.example vc_setup_config.sh
#         編集後、./setup_vc_workspace.sh [path] vc_setup_config.sh を実行
#============================================================

# 自動確認をスキップする（trueに設定すると確認なしで進行）
AUTO_APPROVE=false

# リポジトリを自動クローンする（trueに設定すると確認なしでクローン）
AUTO_CLONE=false

# ファンド基本設定
DEFAULT_FUND_NAME="TechVentures_Fund"
DEFAULT_FUND_SIZE="50億円"
DEFAULT_INVESTMENT_FOCUS="Early to Growth Stage Tech Startups"

# VC特化ルールリポジトリ
# 形式: "GitリポジトリURL|ターゲットパス"
RULE_REPOS=(
  "https://github.com/miyatti777/vc_rules.git|.cursor/rules/vc"
  # 必要に応じて追加 （追加するときはカンマなどで区切らず、改行のみでOK）
  # "https://github.com/username/custom_vc_rules.git|.cursor/rules/custom_vc"
)

# VC関連スクリプトリポジトリ
SCRIPT_REPOS=(

  # 必要に応じて追加 （追加するときはカンマなどで区切らず、改行のみでOK）
  # "https://github.com/username/vc_automation.git|scripts/automation"
)

# VC投資案件サンプルリポジトリ
PROGRAM_REPOS=(
  # 必要に応じて追加 （追加するときはカンマなどで区切らず、改行のみでOK）
  # "https://github.com/username/portfolio_company_template.git|Stock/programs/$DEFAULT_FUND_NAME/investments/TEMPLATE"
)

# 基本ディレクトリ構造（カスタマイズ可能）
BASE_DIRS=(
  "Flow"
  "Stock"
  "Archived"
  "Archived/investments"
  "scripts"
  "scripts/vc"
  ".cursor/rules"
  ".cursor/rules/vc"
  ".cursor/rules/basic"
  "Stock/programs"
  "Stock/programs/$DEFAULT_FUND_NAME"
  "Stock/programs/$DEFAULT_FUND_NAME/investments"
  "Stock/programs/$DEFAULT_FUND_NAME/fund_documents"
  "Stock/programs/$DEFAULT_FUND_NAME/lp_reports"
  "Stock/shared"
  "Stock/shared/templates"
  "Stock/shared/templates/vc"
  # 必要に応じて追加
)

# 投資フォーカス設定
TARGET_SECTORS=("EdTech" "FinTech" "HealthTech" "SaaS" "AI/ML" "Enterprise Software")
TARGET_STAGES=("Pre-Seed" "Seed" "Series A" "Series B")

# 投資条件設定
MIN_INVESTMENT="1000万円"
MAX_INVESTMENT="10億円"
TARGET_IRR="25%以上"
TARGET_MULTIPLE="3倍以上"
TARGET_EXIT_PERIOD="5-7年"

# 投資委員会設定
IC_FREQUENCY="月2回"
IC_MEMBERS=("Managing Partner" "Investment Partner" "LP Representative")

# ポートフォリオ監視設定
MONITORING_FREQUENCY="月次"
BOARD_MEETING_FREQUENCY="四半期"

# レポート設定
LP_REPORT_FREQUENCY="四半期"
PORTFOLIO_REVIEW_FREQUENCY="月次" 