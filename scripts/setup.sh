#!/bin/bash
# ============================================================
#  初回セットアップスクリプト
#  使い方: ターミナルで以下を実行
#    bash scripts/setup.sh
# ============================================================

set -e

# --- 色付き出力 ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}✔ $1${NC}"; }
warn()  { echo -e "${YELLOW}⚠ $1${NC}"; }
error() { echo -e "${RED}✖ $1${NC}"; }
step()  { echo -e "\n${BOLD}── $1 ──${NC}"; }

# --- プロジェクトルートに移動 ---
cd "$(dirname "$0")/.."

echo ""
echo "======================================"
echo "  team-design-test セットアップ"
echo "======================================"
echo ""

# ============================================================
# 1. Homebrew
# ============================================================
step "1/4: Homebrew の確認"

if command -v brew &>/dev/null; then
  info "Homebrew はインストール済みです"
else
  warn "Homebrew が見つかりません。インストールします..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apple Silicon Mac の場合 PATH を通す
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    # .zprofile に追記（まだなければ）
    if ! grep -q '/opt/homebrew/bin/brew' ~/.zprofile 2>/dev/null; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
      info ".zprofile に Homebrew の PATH を追加しました"
    fi
  fi

  if command -v brew &>/dev/null; then
    info "Homebrew をインストールしました"
  else
    error "Homebrew のインストールに失敗しました。手動でインストールしてください:"
    echo "  https://brew.sh"
    exit 1
  fi
fi

# ============================================================
# 2. uv (uvx)
# ============================================================
step "2/4: uv の確認"

if command -v uvx &>/dev/null; then
  info "uv はインストール済みです ($(uv --version))"
else
  warn "uv が見つかりません。インストールします..."
  brew install uv
  if command -v uvx &>/dev/null; then
    info "uv をインストールしました"
  else
    error "uv のインストールに失敗しました"
    exit 1
  fi
fi

# ============================================================
# 3. .env ファイル
# ============================================================
step "3/4: .env ファイルの作成"

if [[ -f .env ]]; then
  info ".env はすでに存在します"
else
  cp .env.sample .env
  info ".env.sample をコピーして .env を作成しました"
fi

# --- 必須項目のチェックと入力 ---
needs_input=false

check_env_var() {
  local var_name="$1"
  local prompt_text="$2"
  local current_value
  current_value=$(grep "^${var_name}=" .env | cut -d'=' -f2-)

  if [[ -z "$current_value" ]]; then
    echo ""
    echo -e "${YELLOW}${prompt_text}${NC}"
    read -r value
    if [[ -n "$value" ]]; then
      # .env 内の該当行を置換
      if grep -q "^${var_name}=" .env; then
        sed -i '' "s|^${var_name}=.*|${var_name}=${value}|" .env
      else
        echo "${var_name}=${value}" >> .env
      fi
      info "${var_name} を設定しました"
    else
      warn "${var_name} はスキップしました（後で .env を直接編集してください）"
      needs_input=true
    fi
  else
    info "${var_name} は設定済みです"
  fi
}

echo ""
echo "Google Workspace 連携に必要な情報を入力します。"
echo "わからない場合は Enter でスキップできます（後で設定可能）。"
echo ""
echo "※ GOOGLE_OAUTH_CLIENT_ID と CLIENT_SECRET は管理者から共有されたものを貼り付けてください。"

check_env_var "GOOGLE_OAUTH_CLIENT_ID" \
  "GOOGLE_OAUTH_CLIENT_ID を入力してください（管理者から共有された値）:"

check_env_var "GOOGLE_OAUTH_CLIENT_SECRET" \
  "GOOGLE_OAUTH_CLIENT_SECRET を入力してください（管理者から共有された値）:"

check_env_var "USER_GOOGLE_EMAIL" \
  "あなたの Google メールアドレスを入力してください（例: taro@x-point-1.net）:"

# ============================================================
# 4. 完了
# ============================================================
step "4/4: セットアップ完了"

echo ""
if [[ "$needs_input" = true ]]; then
  warn "一部の設定がスキップされました。.env ファイルを直接編集して埋めてください:"
  echo "  open .env"
  echo ""
fi

echo "======================================"
echo -e "  ${GREEN}セットアップが完了しました！${NC}"
echo "======================================"
echo ""
echo "次のステップ:"
echo "  1. Claude Code を起動してください"
echo "  2. /briefing と入力してみてください"
echo "  3. 認証用の URL が表示されるのでクリックして Google ログインしてください"
echo "  4. ログイン後、もう一度 /briefing を実行すれば使えるようになります"
echo ""
