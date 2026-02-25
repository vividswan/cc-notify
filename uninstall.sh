#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[cc-notify]${NC} $1"; }
warn() { echo -e "${YELLOW}[cc-notify]${NC} $1"; }

# 1. Claude Code 스크립트 제거
if [ -f ~/.claude/notify-complete.sh ]; then
  rm ~/.claude/notify-complete.sh
  info "~/.claude/notify-complete.sh 제거됨"
fi

if [ -f ~/.claude/notify-waiting.sh ]; then
  rm ~/.claude/notify-waiting.sh
  info "~/.claude/notify-waiting.sh 제거됨"
fi

if [ -f ~/.claude/settings.json ] && grep -q 'notify-complete.sh\|notify-waiting.sh' ~/.claude/settings.json; then
  warn "~/.claude/settings.json에서 hooks 설정을 수동으로 제거해주세요."
fi

# 2. Cursor CLI 스크립트 제거
if [ -f ~/.cursor/notify-complete.sh ]; then
  rm ~/.cursor/notify-complete.sh
  info "~/.cursor/notify-complete.sh 제거됨"
fi

if [ -f ~/.cursor/hooks.json ] && grep -q 'notify-complete.sh' ~/.cursor/hooks.json; then
  warn "~/.cursor/hooks.json에서 hooks 설정을 수동으로 제거해주세요."
fi

echo ""
info "제거 완료!"
