#!/bin/sh

# Make sure we use defaults everywhere.
: ${TITLE:="TMStadium@nadeo"}
: ${TITLE_PACK_URL:="https://v4.live.maniaplanet.com/ingame/public/titles/download/TMStadium@nadeo.Title.Pack.gbx"}
: ${TITLE_PACK_FILE:=""}
: ${DEDICATED_CFG:="config.txt"}
: ${MATCH_SETTINGS:="MatchSettings/default.txt"}
: ${SERVER_NAME:="My Docker Server"}
: ${FORCE_IP_PORT:="2350"}

# We are required to get the public ip if we don't have it in our env currently.
if [ "$FORCE_IP_ADDRESS" = "" ]
then
   FORCE_IP_ADDRESS=`wget -4 -qO- http://ifconfig.co`
fi
echo "=> Going to run on forced IP: ${FORCE_IP_ADDRESS} and port: ${FORCE_IP_PORT}"

# Copy the configuration files if not yet copied.
mkdir -p /dedicated/UserData/Config
mkdir -p /dedicated/UserData/Packs
mkdir -p /dedicated/UserData/Maps/MatchSettings
# if [ ! -f /dedicated/UserData/Config/config.txt ]; then
#     cp /dedicated-configs/config.txt /dedicated/UserData/Config/config.txt
# fi
# if [ ! -f /dedicated/UserData/Maps/MatchSettings/default.txt ]; then
#     cp /dedicated-configs/matchsettings.txt /dedicated/UserData/Maps/MatchSettings/default.txt
# fi

# Download title.
# TODO: Check if update is required first.
echo "=> Downloading newest title version"
if [ "$TITLE_PACK_FILE" = "" ]
then
    wget ${TITLE_PACK_URL} -qP ./UserData/Packs/
else
    wget ${TITLE_PACK_URL} -qO ./UserData/Packs/${TITLE_PACK_FILE}
fi

# Start dedicated.
echo "=> Starting server, login=${LOGIN}"
./ManiaPlanetServer $@ \
    /nodaemon \
    /forceip=${FORCE_IP_ADDRESS}:${FORCE_IP_PORT} \
    /title=${TITLE} \
    /dedicated_cfg=${DEDICATED_CFG} \
    /game_settings=${MATCH_SETTINGS} \
    /login=${LOGIN} \
    /password=${PASSWORD} \
    /servername=${SERVER_NAME} \
