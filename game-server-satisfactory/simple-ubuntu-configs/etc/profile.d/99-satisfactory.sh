#!/bin/sh

# Game Server Service name
GAME_SERVER_SERVICE="satisfactory"

# Game Server Information
echo "===================="
echo "GAME SERVER INFO"

# Show game server status
echo "Satisfactory Server: $(systemctl show -p SubState --value $GAME_SERVER_SERVICE)"

# Show game server uptime/downtime
echo "Since: $(systemctl show --property=ActiveEnterTimestamp --value $GAME_SERVER_SERVICE)"

echo "===================="
