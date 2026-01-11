# Claude Code Notify

Clickable macOS notifications for Claude Code permission prompts. When Claude Code needs permission, you get a notification that **clicks to focus the terminal**.

![Demo](demo.gif)

## Features

- 🔔 **Native macOS notifications** when Claude Code requests permission
- 🖱️ **Click to focus** - clicking the notification opens Cursor and focuses the terminal
- 🔊 **Sound alert** - never miss a permission prompt
- ⏱️ **10-second timeout** - notification stays visible for you to respond

## Requirements

- macOS
- [Claude Code](https://claude.ai/code) CLI
- [terminal-notifier](https://github.com/julienXX/terminal-notifier) (installed via Homebrew)
- [jq](https://jqlang.github.io/jq/) (for JSON parsing)

## Installation

### 1. Install dependencies

```bash
brew install terminal-notifier jq
```

### 2. Run the install script

```bash
curl -fsSL https://raw.githubusercontent.com/harnguyen/claude-code-notify/main/install.sh | bash
```

Or manually:

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/claude-code-notify.git
cd claude-code-notify

# Run installer
./install.sh
```

### 3. Enable notifications

1. **System Settings** → **Notifications** → **terminal-notifier**
2. Enable **Allow Notifications**
3. Set alert style to **Alerts** (recommended) or **Banners**

### 4. Enable Accessibility (for auto-focus terminal)

1. **System Settings** → **Privacy & Security** → **Accessibility**
2. Add **Terminal** (or your terminal app) to the allowed list

## Manual Installation

If you prefer to set it up manually:

### 1. Create the focus script

```bash
mkdir -p ~/.claude/scripts
cat > ~/.claude/scripts/focus-terminal.sh << 'EOF'
#!/bin/bash
# Focus Cursor and open terminal panel
osascript -e 'tell application "Cursor" to activate' \
          -e 'delay 0.2' \
          -e 'tell application "System Events" to keystroke "`" using control down'
EOF
chmod +x ~/.claude/scripts/focus-terminal.sh
```

### 2. Add the hook to your Claude Code settings

Add this to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "payload=$(cat); type=$(echo \"$payload\" | jq -r .notification_type); msg=$(echo \"$payload\" | jq -r .message); if [ \"$type\" = \"permission_prompt\" ]; then terminal-notifier -title 'Claude Code' -subtitle 'Permission Required' -message \"$msg\" -timeout 10 -sound default -execute ~/.claude/scripts/focus-terminal.sh; fi"
          }
        ]
      }
    ]
  }
}
```

## Customization

### Change the terminal app

Edit `~/.claude/scripts/focus-terminal.sh`:

```bash
# For VS Code
osascript -e 'tell application "Visual Studio Code" to activate' ...

# For iTerm
osascript -e 'tell application "iTerm" to activate' ...

# For Terminal.app
osascript -e 'tell application "Terminal" to activate' ...
```

### Change notification timeout

Edit the `-timeout` value in your settings.json (in seconds):

```bash
-timeout 10  # 10 seconds
-timeout 30  # 30 seconds
```

### Change notification sound

Replace `-sound default` with other macOS sounds:

```bash
-sound "Glass"
-sound "Ping"
-sound "Pop"
-sound "Purr"
```

## Troubleshooting

### Notification not appearing

1. Check **Do Not Disturb** is OFF
2. Verify terminal-notifier is in **System Settings** → **Notifications**
3. Test manually: `terminal-notifier -message "Test"`

### Click doesn't focus terminal

1. Grant Accessibility permissions to your terminal app
2. Test the script: `~/.claude/scripts/focus-terminal.sh`

### Wrong app focuses

Edit the script to use your preferred app name (see Customization above).

## How it works

1. Claude Code triggers a `Notification` hook when it needs permission
2. The hook script parses the JSON payload using `jq`
3. If it's a `permission_prompt`, it calls `terminal-notifier`
4. Clicking the notification runs `focus-terminal.sh`
5. The script activates Cursor and sends `Ctrl+`` to focus the terminal

## License

MIT

## Contributing

PRs welcome! Please open an issue first to discuss major changes.
