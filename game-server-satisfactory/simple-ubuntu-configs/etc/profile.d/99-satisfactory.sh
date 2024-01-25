#!/bin/sh

# /etc/update-motd.d/99-game-server-status
# https://linuxconfig.org/how-to-change-welcome-message-motd-on-ubuntu-18-04-server


# Game Server Service name
GAME_SERVER_SERVICE="satisfactory"


# Game Server Information
echo "===================="
echo "GAME SERVER INFO"


# Show game server status
printf "Satisfactory Server: "
systemctl show -p SubState --value $GAME_SERVER_SERVICE

# Show game server uptime/downtime
printf "Since: "
systemctl show --property=ActiveEnterTimestamp --value $GAME_SERVER_SERVICE

echo "===================="

