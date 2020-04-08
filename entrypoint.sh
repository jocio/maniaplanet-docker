#!/bin/sh

# Make sure we use defaults everywhere.
: ${SERVER_LOGIN:=dedicated_login}
: ${SERVER_PASSWORD:=dedicated_password}
: ${VALIDATION_KEY:=AAAAA}
: ${SERVER_NAME:=$f00$zMy Server Name}
: ${SERVER_COMMENT:=}
: ${SERVER_PORT:=2350}
: ${SERVER_P2P_PORT:=3450}
: ${XMLRPC_PORT:=5000}
: ${TITLE:=TMStadium@nadeo}
: ${TITLE_PACK_URL:=https://v4.live.maniaplanet.com/ingame/public/titles/download/TMStadium@nadeo.Title.Pack.gbx}
: ${TITLE_PACK_FILE:=TMStadium@nadeo.Title.Pack.gbx}

# Copy the default configuration files and apply environement values.
mkdir -p ${PROJECT_DIR}/UserData/Config
mkdir -p ${PROJECT_DIR}/UserData/Packs
mkdir -p ${PROJECT_DIR}/UserData/Maps/MatchSettings

CONFIG_SOURCE_FILE_FULL="${PROJECT_DIR}/config.default.xml"
CONFIG_TARGET_FILE="config.${SERVER_LOGIN}.xml"
CONFIG_TARGET_FILE_FULL="${PROJECT_DIR}/UserData/Config/${CONFIG_TARGET_FILE}"
if [[ -f ${CONFIG_TARGET_FILE_FULL} ]] && [[ ${CONFIG_FILE_FORCE_OVERWRITE} -ne 1 ]]; then
    echo "=> File ${CONFIG_TARGET_FILE_FULL} existing but it should not be overwrited !"
elif [[ ! -f ${CONFIG_SOURCE_FILE_FULL} ]]; then
    echo "=> ERROR : File ${CONFIG_SOURCE_FILE_FULL} not existing !"
    exit 1
else
    if [[ ! -f ${CONFIG_TARGET_FILE_FULL} ]]; then
        echo "=> File ${CONFIG_TARGET_FILE_FULL} not existing : copy from ${CONFIG_TARGET_FILE_FULL}"
    fi
    cp ${CONFIG_SOURCE_FILE_FULL} ${CONFIG_TARGET_FILE_FULL}
    echo "=> File ${CONFIG_TARGET_FILE_FULL} will be updated using env variable"
    sed -i "s|#SERVER_LOGIN#|${SERVER_LOGIN}|g" ${CONFIG_TARGET_FILE_FULL}
    sed -i "s|#SERVER_PASSWORD#|${SERVER_PASSWORD}|g" ${CONFIG_TARGET_FILE_FULL}
    sed -i "s|#VALIDATION_KEY#|${VALIDATION_KEY}|g" ${CONFIG_TARGET_FILE_FULL}
    sed -i "s|#SERVER_NAME#|${SERVER_NAME}|g" ${CONFIG_TARGET_FILE_FULL}
    sed -i "s|#SERVER_COMMENT#|${SERVER_COMMENT}|g" ${CONFIG_TARGET_FILE_FULL}
    sed -i "s|#USER_PASSWORD#|${USER_PASSWORD}|g" ${CONFIG_TARGET_FILE_FULL}
    sed -i "s|#SERVER_PORT#|${SERVER_PORT}|g" ${CONFIG_TARGET_FILE_FULL}
    sed -i "s|#SERVER_P2P_PORT#|${SERVER_P2P_PORT}|g" ${CONFIG_TARGET_FILE_FULL}
    sed -i "s|#XMLRPC_PORT#|${XMLRPC_PORT}|g" ${CONFIG_TARGET_FILE_FULL}
    sed -i "s|#TITLE#|${TITLE}|g" ${CONFIG_TARGET_FILE_FULL}
    echo "=> File ${CONFIG_TARGET_FILE_FULL} updated"
fi

MATCHSETTINGS_SOURCE_FILE_FULL="${PROJECT_DIR}/matchsettings.default.xml"
MATCHSETTINGS_TARGET_FILE="matchsettings.${SERVER_LOGIN}.xml"
MATCHSETTINGS_TARGET_FILE_FULL="${PROJECT_DIR}/UserData/Maps/MatchSettings/${MATCHSETTINGS_TARGET_FILE}"
if [[ -f ${MATCHSETTINGS_TARGET_FILE_FULL} ]] && [[ ${MATCHSETTINGS_FILE_FORCE_OVERWRITE} -ne 1 ]]; then
    echo "=> File ${MATCHSETTINGS_TARGET_FILE_FULL} existing but it should not be overwrited !"
elif [[ ! -f ${MATCHSETTINGS_SOURCE_FILE_FULL} ]]; then
    echo "=> ERROR : File ${MATCHSETTINGS_SOURCE_FILE_FULL} not existing !"
    exit 1
else
    if [[ ! -f ${MATCHSETTINGS_TARGET_FILE_FULL} ]]; then
        echo "=> File ${MATCHSETTINGS_TARGET_FILE_FULL} not existing : copy from ${MATCHSETTINGS_SOURCE_FILE_FULL}"
    fi
    cp ${MATCHSETTINGS_SOURCE_FILE_FULL} ${MATCHSETTINGS_TARGET_FILE_FULL}
    echo "=> File ${MATCHSETTINGS_TARGET_FILE_FULL} will be updated using env variable"
    sed -i "s|#MATCHSETTINGS_SCRIPT_NAME#|${MATCHSETTINGS_SCRIPT_NAME}|g" ${MATCHSETTINGS_TARGET_FILE_FULL}
    # Creation of the map files list regarding the folder defined in the env file
    MAPS_FOLDER=${PROJECT_DIR}/UserData/Maps
    MATCHSETTINGS_MAPS_FOLDER_FULL=${MAPS_FOLDER}/${MATCHSETTINGS_MAPS_FOLDER}
    if [[ ! ${MATCHSETTINGS_MAPS_FOLDER_FULL} ]]; then
        echo "=> MATCHSETTINGS_MAPS_FOLDER defined in env file is not a Folder or not existing : MATCHSETTINGS_MAPS_FOLDER_FULL = #${MATCHSETTINGS_MAPS_FOLDER_FULL}#"
    else
        TMP_FILE=maps_list.tmp
        # TMP_FILE_MAJ=maps_list_maj.tmp
        rm -f ${TMP_FILE}
        # rm -f ${TMP_FILE_MAJ}
        # Get all the map files recurcively in the folder define in the env file
        find ${MAPS_FOLDER}/${MATCHSETTINGS_MAPS_FOLDER} -type f -name "*.Map.Gbx" > ${TMP_FILE}
        # Delete begin of the path (because matchsettings file need relative path)
        sed -i "s|^${MAPS_FOLDER}/||g" ${TMP_FILE}
        while read line; do
            # Add map file to the list
            sed -i "s|#MAP_FILE_LIST#|    <map><file>${line}</file></map>\n#MAP_FILE_LIST#|g" ${MATCHSETTINGS_TARGET_FILE_FULL}
        done < ${TMP_FILE}
        rm -f ${TMP_FILE}
        # Delete key word in the file
        sed -i "s|#MAP_FILE_LIST#||g" ${MATCHSETTINGS_TARGET_FILE_FULL}
    fi
    echo "=> File ${MATCHSETTINGS_TARGET_FILE_FULL} updated"
fi

# Download title.
# TODO: Check if update is required first.
echo "=> Downloading newest title version"
if [[ "$TITLE_PACK_FILE" = "" ]]; then
    wget ${TITLE_PACK_URL} -qP ./UserData/Packs/
else
    wget ${TITLE_PACK_URL} -qO ./UserData/Packs/${TITLE_PACK_FILE}
fi

# We are required to get the public ip if we don't have it in our env currently.
if [[ "$FORCE_IP_ADDRESS" = "" ]]; then
   FORCE_IP_ADDRESS=`wget -4 -qO- http://ifconfig.co`
fi
echo "=> Going to run on forced IP: ${FORCE_IP_ADDRESS} and port: ${SERVER_PORT}"

# Start dedicated.
echo "=> Starting server, login=${SERVER_LOGIN}"
# ./ManiaPlanetServer $@ \
#     /nodaemon \
#     /forceip=${FORCE_IP_ADDRESS}:${SERVER_PORT} \
#     /title=${TITLE} \
#     /dedicated_cfg=${DEDICATED_CFG} \
#     /game_settings=${MATCH_SETTINGS} \
#     /login=${SERVER_LOGIN} \
#     /password=${PASSWORD} \
#     /servername=${SERVER_NAME} \

./ManiaPlanetServer $@ \
    /nodaemon \
    /forceip="${FORCE_IP_ADDRESS}:${SERVER_PORT}" \
    /dedicated_cfg="${CONFIG_TARGET_FILE}" \
    /game_settings="MatchSettings/${MATCHSETTINGS_TARGET_FILE}" \
