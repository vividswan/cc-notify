#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${GREEN}[cc-notify]${NC} $1"; }
warn() { echo -e "${YELLOW}[cc-notify]${NC} $1"; }
error() { echo -e "${RED}[cc-notify]${NC} $1"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 1. alerter 설치 확인
if ! command -v alerter &> /dev/null; then
  info "alerter 설치 중..."
  if ! command -v brew &> /dev/null; then
    error "Homebrew가 필요합니다. https://brew.sh 에서 설치해주세요."
  fi
  brew install vjeantet/tap/alerter
else
  info "alerter 이미 설치됨"
fi

# 2. Claude Code 설정
info "Claude Code 스크립트 복사 중..."
mkdir -p ~/.claude
cp "$SCRIPT_DIR/claude/notify-complete.sh" ~/.claude/notify-complete.sh
cp "$SCRIPT_DIR/claude/notify-waiting.sh" ~/.claude/notify-waiting.sh
chmod +x ~/.claude/notify-complete.sh ~/.claude/notify-waiting.sh

if [ -f ~/.claude/settings.json ] && [ -s ~/.claude/settings.json ]; then
  if grep -q '"hooks"' ~/.claude/settings.json; then
    warn "~/.claude/settings.json에 이미 hooks 설정이 있습니다. 수동으로 확인해주세요."
  else
    info "Claude Code hook 설정 중..."
    # 기존 설정에 hooks 추가
    TMP=$(mktemp)
    jq '. + {
      "hooks": {
        "Stop": [{"hooks": [{"type": "command", "command": "~/.claude/notify-complete.sh"}]}],
        "Notification": [{"hooks": [{"type": "command", "command": "~/.claude/notify-waiting.sh"}]}]
      }
    }' ~/.claude/settings.json > "$TMP" && mv "$TMP" ~/.claude/settings.json
  fi
else
  info "Claude Code hook 설정 중..."
  cat > ~/.claude/settings.json << 'EOF'
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/notify-complete.sh"
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/notify-waiting.sh"
          }
        ]
      }
    ]
  }
}
EOF
fi

# 3. Cursor CLI 설정
info "Cursor CLI 스크립트 복사 중..."
mkdir -p ~/.cursor
cp "$SCRIPT_DIR/cursor/notify-complete.sh" ~/.cursor/notify-complete.sh
chmod +x ~/.cursor/notify-complete.sh

if [ -f ~/.cursor/hooks.json ] && [ -s ~/.cursor/hooks.json ]; then
  if grep -q '"hooks"' ~/.cursor/hooks.json; then
    warn "~/.cursor/hooks.json에 이미 hooks 설정이 있습니다. 수동으로 확인해주세요."
  else
    info "Cursor CLI hook 설정 중..."
    TMP=$(mktemp)
    jq '. + {
      "hooks": {
        "stop": [{"command": "~/.cursor/notify-complete.sh", "type": "command", "timeout": 30}]
      }
    }' ~/.cursor/hooks.json > "$TMP" && mv "$TMP" ~/.cursor/hooks.json
  fi
else
  info "Cursor CLI hook 설정 중..."
  cat > ~/.cursor/hooks.json << 'EOF'
{
  "version": 1,
  "hooks": {
    "stop": [
      {
        "command": "~/.cursor/notify-complete.sh",
        "type": "command",
        "timeout": 30
      }
    ]
  }
}
EOF
fi

echo ""
info "설치 완료!"
