#!/bin/bash
#============================================================
# setup_vc_workspace.sh
# ─ VC特化版AIプロジェクト管理ワークスペースの構築スクリプト
# 
# 使い方: ./setup_vc_workspace.sh [root_directory] [config_file]
#         ./setup_vc_workspace.sh [config_file]
# 例:     ./setup_vc_workspace.sh /Users/username/new_vc_workspace ./vc_setup_config.sh
#         ./setup_vc_workspace.sh vc_setup_config.sh  # カレントディレクトリに作成
#
# VC特化のフォルダ構造を作成し、投資関連テンプレートを配置します
# コンフィグファイルを指定すると、クローンするリポジトリをカスタマイズできます
#============================================================

set -e

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log_vc() {
  echo -e "${PURPLE}[VC-AIPM]${NC} $1"
}

# デフォルト設定
# これらの設定はコンフィグファイルでオーバーライドできます
setup_default_config() {
  # VC特化ルールリポジトリ
  RULE_REPOS=(
    "https://github.com/miyatti777/rules_vc_public.git|.cursor/rules/vc"
    "https://github.com/miyatti777/rules_basic_public.git|.cursor/rules/basic"
  )
  
  # VC関連スクリプトリポジトリ
  SCRIPT_REPOS=(
    "https://github.com/miyatti777/scripts_vc_public.git|scripts/vc"
    "https://github.com/miyatti777/scripts_public.git|scripts"
  )
  
  # VC投資案件サンプルリポジトリ
  PROGRAM_REPOS=(
    "https://github.com/miyatti777/sample_investment_case.git|Stock/programs/Sample_Fund/investments/SampleStartup"
  )
  
  # 自動確認設定
  AUTO_APPROVE=false
  AUTO_CLONE=false
  
  # ファンド設定
  DEFAULT_FUND_NAME="Sample_Fund"
  DEFAULT_FUND_SIZE="10億円"
  DEFAULT_INVESTMENT_FOCUS="Early Stage Tech"
}

# 引数解析
parse_arguments() {
  if [ $# -eq 0 ]; then
    WORKSPACE_ROOT="$(pwd)"
    CONFIG_FILE=""
  elif [ $# -eq 1 ]; then
    if [[ "$1" == *.sh ]]; then
      WORKSPACE_ROOT="$(pwd)"
      CONFIG_FILE="$1"
    else
      WORKSPACE_ROOT="$1"
      CONFIG_FILE=""
    fi
  elif [ $# -eq 2 ]; then
    WORKSPACE_ROOT="$1"
    CONFIG_FILE="$2"
  else
    log_error "使用法: $0 [workspace_directory] [config_file]"
    exit 1
  fi
  
  WORKSPACE_ROOT=$(realpath "$WORKSPACE_ROOT")
  
  if [ -n "$CONFIG_FILE" ] && [ ! -f "$CONFIG_FILE" ]; then
    log_error "設定ファイルが見つかりません: $CONFIG_FILE"
    exit 1
  fi
}

# 設定ファイル読み込み
load_config() {
  setup_default_config
  
  if [ -n "$CONFIG_FILE" ]; then
    log_info "設定ファイルを読み込み中: $CONFIG_FILE"
    source "$CONFIG_FILE"
    log_success "設定ファイルの読み込み完了"
  else
    log_info "デフォルト設定を使用"
  fi
}

# ワークスペース情報表示
show_workspace_info() {
  echo ""
  log_vc "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  log_vc "         VC特化版 AIPM ワークスペース構築"
  log_vc "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo -e "${CYAN}ワークスペースパス:${NC} $WORKSPACE_ROOT"
  echo -e "${CYAN}デフォルトファンド:${NC} $DEFAULT_FUND_NAME"
  echo -e "${CYAN}ファンドサイズ:${NC} $DEFAULT_FUND_SIZE"
  echo -e "${CYAN}投資フォーカス:${NC} $DEFAULT_INVESTMENT_FOCUS"
  echo ""
  
  if [ "$AUTO_APPROVE" != "true" ]; then
    echo -e "${YELLOW}この設定でワークスペースを作成しますか? (y/N):${NC} "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      log_info "セットアップをキャンセルしました"
      exit 0
    fi
  fi
}

# 基本ディレクトリ構造作成
create_base_directories() {
  log_info "基本ディレクトリ構造を作成中..."
  
  TODAY=$(date +%Y-%m-%d)
  YEARMONTH=$(date +%Y%m)
  
  # 基本ディレクトリ
  BASE_DIRS=(
    "Flow"
    "Flow/$YEARMONTH"
    "Flow/$YEARMONTH/$TODAY"
    "Flow/$YEARMONTH/$TODAY/vc"
    "Stock"
    "Stock/programs"
    "Stock/programs/$DEFAULT_FUND_NAME"
    "Stock/programs/$DEFAULT_FUND_NAME/investments"
    "Stock/programs/$DEFAULT_FUND_NAME/fund_documents"
    "Stock/programs/$DEFAULT_FUND_NAME/lp_reports"
    "Stock/shared"
    "Stock/shared/templates"
    "Stock/shared/templates/vc"
    "Archived"
    "Archived/investments"
    "scripts"
    "scripts/vc"
    ".cursor"
    ".cursor/rules"
    ".cursor/rules/vc"
    ".cursor/rules/basic"
  )
  
  for dir in "${BASE_DIRS[@]}"; do
    mkdir -p "$WORKSPACE_ROOT/$dir"
    log_info "  ✓ $dir"
  done
  
  log_success "基本ディレクトリ構造の作成完了"
}

# サンプル投資案件フォルダ作成
create_sample_investment_structure() {
  log_info "サンプル投資案件フォルダを作成中..."
  
  SAMPLE_COMPANY="SampleStartup"
  SAMPLE_PATH="Stock/programs/$DEFAULT_FUND_NAME/investments/$SAMPLE_COMPANY/documents"
  
  # 投資案件ディレクトリ構造
  INVESTMENT_DIRS=(
    "$SAMPLE_PATH/1_deal_sourcing"
    "$SAMPLE_PATH/2_screening" 
    "$SAMPLE_PATH/3_due_diligence"
    "$SAMPLE_PATH/4_investment_decision"
    "$SAMPLE_PATH/5_portfolio_management"
    "$SAMPLE_PATH/5_portfolio_management/board_materials"
    "$SAMPLE_PATH/5_portfolio_management/monitoring_reports"
    "$SAMPLE_PATH/6_exit_strategy"
  )
  
  for dir in "${INVESTMENT_DIRS[@]}"; do
    mkdir -p "$WORKSPACE_ROOT/$dir"
    log_info "  ✓ $dir"
  done
  
  log_success "サンプル投資案件フォルダの作成完了"
}

# リポジトリクローン
clone_repositories() {
  if [ ${#RULE_REPOS[@]} -eq 0 ] && [ ${#SCRIPT_REPOS[@]} -eq 0 ] && [ ${#PROGRAM_REPOS[@]} -eq 0 ]; then
    log_info "クローンするリポジトリが設定されていません"
    return
  fi
  
  log_info "リポジトリをクローン中..."
  
  clone_repo_array() {
    local repos=("$@")
    for repo_config in "${repos[@]}"; do
      IFS='|' read -r repo_url target_path <<< "$repo_config"
      
      if [ "$AUTO_CLONE" != "true" ]; then
        echo -e "${YELLOW}$repo_url を $target_path にクローンしますか? (y/N):${NC} "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
          log_info "  スキップ: $repo_url"
          continue
        fi
      fi
      
      local full_target_path="$WORKSPACE_ROOT/$target_path"
      if [ -d "$full_target_path" ] && [ "$(ls -A "$full_target_path" 2>/dev/null)" ]; then
        log_warning "  既存ディレクトリ: $target_path (スキップ)"
        continue
      fi
      
      log_info "  クローン中: $repo_url → $target_path"
      if git clone "$repo_url" "$full_target_path" 2>/dev/null; then
        log_success "  ✓ クローン完了: $target_path"
      else
        log_warning "  クローンに失敗しました: $repo_url"
      fi
    done
  }
  
  if [ ${#RULE_REPOS[@]} -gt 0 ]; then
    log_info "VC特化ルールリポジトリ:"
    clone_repo_array "${RULE_REPOS[@]}"
  fi
  
  if [ ${#SCRIPT_REPOS[@]} -gt 0 ]; then
    log_info "VC関連スクリプトリポジトリ:"
    clone_repo_array "${SCRIPT_REPOS[@]}"
  fi
  
  if [ ${#PROGRAM_REPOS[@]} -gt 0 ]; then
    log_info "投資案件サンプルリポジトリ:"
    clone_repo_array "${PROGRAM_REPOS[@]}"
  fi
}

# VC特化設定ファイル作成
create_vc_config_files() {
  log_info "VC特化設定ファイルを作成中..."
  
  # .gitignore
  cat > "$WORKSPACE_ROOT/.gitignore" << 'EOF'
# VC特化版AIPM .gitignore

# 機密情報
**/confidential/
**/private/
**/dd_materials/
**/financial_data/
*.xls
*.xlsx
*.pdf
*_confidential.*

# 一時ファイル
.DS_Store
Thumbs.db
*.tmp
*.log
*.cache

# IDEファイル
.vscode/
.idea/
*.swp
*.swo

# OS生成ファイル
Icon?
ehthumbs.db

# VC特化除外
Flow/**/archived/
Stock/**/archived/
*.financial_model.*
*_valuation_*
*_term_sheet_*
*_confidential_*
EOF

  # ファンド設定ファイル
  cat > "$WORKSPACE_ROOT/fund_config.sh" << EOF
#!/bin/bash
# VC特化版AIPM ファンド設定ファイル

# ファンド基本情報
FUND_NAME="$DEFAULT_FUND_NAME"
FUND_SIZE="$DEFAULT_FUND_SIZE"
FUND_VINTAGE="$(date +%Y)"
INVESTMENT_FOCUS="$DEFAULT_INVESTMENT_FOCUS"

# 投資方針
MIN_INVESTMENT="5000万円"
MAX_INVESTMENT="5億円"
TARGET_SECTORS=("EdTech" "FinTech" "HealthTech" "SaaS")
TARGET_STAGES=("Seed" "Series A" "Series B")

# 投資委員会設定
IC_FREQUENCY="月2回"
IC_MEMBERS=("GP1" "GP2" "LP代表")

# ポートフォリオ監視設定
MONITORING_FREQUENCY="月次"
BOARD_MEETING_FREQUENCY="四半期"

# Exit設定
TARGET_EXIT_PERIOD="5-7年"
TARGET_IRR="25%以上"
TARGET_MULTIPLE="3倍以上"
EOF

  log_success "VC特化設定ファイルの作成完了"
}

# README作成
create_workspace_readme() {
  log_info "ワークスペースREADMEを作成中..."
  
  cat > "$WORKSPACE_ROOT/README.md" << EOF
# VC特化版 AIPM ワークスペース

## ワークスペース情報

- **ファンド名**: $DEFAULT_FUND_NAME
- **ファンドサイズ**: $DEFAULT_FUND_SIZE  
- **投資フォーカス**: $DEFAULT_INVESTMENT_FOCUS
- **作成日**: $(date +%Y-%m-%d)

## ディレクトリ構造

\`\`\`
$WORKSPACE_ROOT/
├── Flow/                     # ドラフト・作業中ファイル
│   └── YYYYMM/
│       └── YYYY-MM-DD/
│           └── vc/           # VC関連ドラフト
├── Stock/                    # 確定版ファイル
│   ├── programs/
│   │   └── $DEFAULT_FUND_NAME/
│   │       ├── investments/  # 投資案件別フォルダ
│   │       ├── fund_documents/
│   │       └── lp_reports/
│   └── shared/
│       └── templates/
│           └── vc/           # VC特化テンプレート
├── Archived/                 # アーカイブ
├── scripts/                  # 自動化スクリプト
│   └── vc/                   # VC特化スクリプト
└── .cursor/
    └── rules/
        ├── vc/               # VC特化ルール
        └── basic/            # 基本ルール
\`\`\`

## 基本的な使い方

### システム起動
\`\`\`
VC
\`\`\`

### 投資検討開始
\`\`\`
投資機会評価
初期スクリーニング
市場分析
\`\`\`

### Due Diligence
\`\`\`
商業DD
財務DD
技術DD
法務DD
経営陣評価
\`\`\`

### 投資判断
\`\`\`
Investment Memo
バリュエーション分析
投資委員会資料
Term Sheet
\`\`\`

### ポートフォリオ管理
\`\`\`
ポートフォリオ監視
取締役会準備
\`\`\`

### Exit戦略
\`\`\`
Exit計画
IPO準備評価
リターン分析
\`\`\`

## 文書確定
\`\`\`
確定反映して
\`\`\`

## 設定ファイル

- \`fund_config.sh\`: ファンド設定
- \`.cursor/rules/vc/\`: VC特化ルール
- \`scripts/vc/\`: VC自動化スクリプト

## サポート

詳細な使用方法は以下のREADMEを参照:
- [VC特化ルール](.cursor/rules/vc/README.md)
- [テストプロンプト](.cursor/rules/vc/TEST_PROMPTS.md)

---

**ワークスペース作成**: $(date +"%Y-%m-%d %H:%M:%S")  
**システムバージョン**: VC-AIPM v1.0
EOF

  log_success "ワークスペースREADMEの作成完了"
}

# 権限設定
set_permissions() {
  log_info "ファイル権限を設定中..."
  
  # スクリプトファイルに実行権限付与
  find "$WORKSPACE_ROOT/scripts" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
  chmod +x "$WORKSPACE_ROOT/fund_config.sh" 2>/dev/null || true
  
  log_success "権限設定完了"
}

# 完了メッセージ表示
show_completion_message() {
  echo ""
  log_vc "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  log_vc "        VC特化版 AIPM ワークスペース構築完了!"
  log_vc "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo -e "${GREEN}✓ ワークスペースパス:${NC} $WORKSPACE_ROOT"
  echo -e "${GREEN}✓ ファンド設定:${NC} $DEFAULT_FUND_NAME ($DEFAULT_FUND_SIZE)"
  echo ""
  echo -e "${CYAN}次のステップ:${NC}"
  echo "1. ワークスペースディレクトリに移動:"
  echo "   cd $WORKSPACE_ROOT"
  echo ""
  echo "2. システムの動作確認:"
  echo "   VC"
  echo ""
  echo "3. テストプロンプトの実行:"
  echo "   投資機会評価"
  echo ""
  echo -e "${CYAN}参考資料:${NC}"
  echo "- README.md: ワークスペース概要"
  echo "- .cursor/rules/vc/README.md: 詳細マニュアル"
  echo "- .cursor/rules/vc/TEST_PROMPTS.md: テスト手順"
  echo ""
  log_success "VC特化版AIPMワークスペースの準備が完了しました!"
}

# メイン実行
main() {
  parse_arguments "$@"
  load_config
  show_workspace_info
  
  cd "$WORKSPACE_ROOT" || exit 1
  
  create_base_directories
  create_sample_investment_structure
  clone_repositories
  create_vc_config_files
  create_workspace_readme
  set_permissions
  
  show_completion_message
}

# スクリプト実行
main "$@" 