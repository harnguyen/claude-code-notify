#!/bin/bash
set -e

echo "🔔 Installing Claude Code Notify..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check dependencies
echo "Checking dependencies..."

if ! command -v terminal-notifier &> /dev/null; then
    echo -e "${YELLOW}terminal-notifier not found. Installing via Homebrew...${NC}"
    if command -v brew &> /dev/null; then
        brew install terminal-notifier
    else
        echo -e "${RED}Error: Homebrew not found. Please install terminal-notifier manually:${NC}"
        echo "  brew install terminal-notifier"
        exit 1
    fi
fi

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}jq not found. Installing via Homebrew...${NC}"
    if command -v brew &> /dev/null; then
        brew install jq
    else
        echo -e "${RED}Error: Homebrew not found. Please install jq manually:${NC}"
        echo "  brew install jq"
        exit 1
    fi
fi

echo -e "${GREEN}✓ Dependencies installed${NC}"

# Create scripts directory
mkdir -p ~/.claude/scripts

# Create focus-terminal script
cat > ~/.claude/scripts/focus-terminal.sh << 'EOF'
#!/bin/bash
# Focus Cursor and open terminal panel
osascript -e 'tell application "Cursor" to activate' \
          -e 'delay 0.2' \
          -e 'tell application "System Events" to keystroke "`" using control down'
EOF

chmod +x ~/.claude/scripts/focus-terminal.sh
echo -e "${GREEN}✓ Created ~/.claude/scripts/focus-terminal.sh${NC}"

# Check if settings.json exists
SETTINGS_FILE=~/.claude/settings.json

if [ ! -f "$SETTINGS_FILE" ]; then
    echo "Creating new settings.json..."
    cat > "$SETTINGS_FILE" << 'EOF'
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
EOF
    echo -e "${GREEN}✓ Created ~/.claude/settings.json${NC}"
else
    echo -e "${YELLOW}~/.claude/settings.json already exists.${NC}"
    echo ""
    echo "Add this to your hooks section manually:"
    echo ""
    cat << 'EOF'
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
EOF
    echo ""
fi

# Test notification
echo ""
echo "Testing notification..."
terminal-notifier -title "Claude Code Notify" -subtitle "Installation Complete" -message "Click me to test focus!" -timeout 10 -sound default -execute ~/.claude/scripts/focus-terminal.sh

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Enable notifications: System Settings → Notifications → terminal-notifier"
echo "2. Enable accessibility: System Settings → Privacy & Security → Accessibility → Add Terminal"
echo ""
echo "A test notification was sent - click it to verify everything works!"
