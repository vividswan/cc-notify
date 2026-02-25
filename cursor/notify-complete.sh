#!/bin/bash

# tmux에서 실행된 경우에만 알림
if [ -z "$TMUX" ]; then
  exit 0
fi

# tmux 세션 정보 가져오기
if [ -n "$TMUX" ]; then
  WINDOW_NAME=$(tmux display-message -t "$TMUX_PANE" -p '#W')
  SESSION_NAME=$(tmux display-message -t "$TMUX_PANE" -p '#S')
  SUBTITLE="${SESSION_NAME} - ${WINDOW_NAME}"
else
  SUBTITLE=$(basename "$PWD")
fi

# alerter를 백그라운드로 실행 (클릭 감지 후 iTerm 활성화)
(
  result=$(/opt/homebrew/bin/alerter \
    --title "Cursor Agent" \
    --subtitle "$SUBTITLE" \
    --message "작업이 완료되었습니다" \
    --actions "보기" \
    --sound default \
    --timeout 10 2>&1)

  if [[ "$result" = "보기" || "$result" = "@CONTENTCLICKED" ]]; then
    /usr/bin/open -a iTerm
    if [ -n "$TMUX_PANE" ]; then
      tmux select-window -t "${SESSION_NAME}:${WINDOW_NAME}"
      tmux select-pane -t "$TMUX_PANE"
    fi
  fi
) &
disown

exit 0
