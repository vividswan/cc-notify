# cc-notify

Claude Code & Cursor CLI notification for macOS.

tmux에서 AI 코딩 에이전트를 사용할 때, 작업 완료/입력 대기를 macOS 알림으로 알려줍니다.
알림의 "보기"를 클릭하면 해당 tmux session/window/pane으로 바로 이동합니다.

## Features

| | Claude Code | Cursor CLI |
|---|---|---|
| 작업 완료 알림 | `Stop` hook | `stop` hook |
| 입력 대기 알림 | `Notification` hook | - |
| 클릭 시 tmux window/pane 전환 | O | O |

## Requirements

- macOS
- [alerter](https://github.com/vjeantet/alerter) — macOS 알림 전송 도구
- tmux
- [iTerm2](https://iterm2.com/) (또는 다른 터미널)

## Install

```bash
git clone https://github.com/vividswan/cc-notify.git
cd cc-notify
./install.sh
```

alerter 설치, 스크립트 복사, hook 설정까지 자동으로 완료됩니다.

<details>
<summary>수동 설치</summary>

### 1. alerter 설치

```bash
brew install vjeantet/tap/alerter
```

### 2. 스크립트 복사

```bash
# Claude Code
cp claude/notify-complete.sh ~/.claude/notify-complete.sh
cp claude/notify-waiting.sh ~/.claude/notify-waiting.sh
chmod +x ~/.claude/notify-complete.sh ~/.claude/notify-waiting.sh

# Cursor CLI
cp cursor/notify-complete.sh ~/.cursor/notify-complete.sh
chmod +x ~/.cursor/notify-complete.sh
```

### 3. Hook 설정

**Claude Code** — `~/.claude/settings.json`

```json
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
```

**Cursor CLI** — `~/.cursor/hooks.json`

```json
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
```

</details>

## How It Works

1. tmux에서 AI 에이전트가 작업을 완료하거나 입력을 기다리면 hook이 실행됩니다
2. [alerter](https://github.com/vjeantet/alerter)가 macOS 알림을 전송합니다
3. 알림의 "보기" 버튼을 클릭하면 해당 tmux session/window/pane으로 자동 전환됩니다

> tmux 환경에서만 동작합니다. tmux 외 환경(IDE 등)에서는 알림을 보내지 않습니다.

## Why alerter?

`terminal-notifier`는 macOS 최신 버전(Sequoia+)에서 알림 클릭 시 앱 활성화(`-activate`)가 동작하지 않습니다.
`alerter`는 클릭 결과를 stdout으로 반환하기 때문에, 스크립트에서 클릭을 감지하고 원하는 앱을 직접 열 수 있습니다.

## License

MIT
