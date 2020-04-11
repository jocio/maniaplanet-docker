# Dockerized Maniaplanet Dedicated (multiple servers) + ManiaControl
Maniaplanet multiple dedicated servers with ManiaControl (using docker containers)

## Requirements

A machine with Docker engine.

## Usage

### Directly from CLI

We advice you to use the docker-compose method. CLI is not documented.

### In docker-compose file

Env file:

```
# Dedicated Maniaplanet Server
SERVER_LOGIN=dedicated_login # Mandatory : https://www.maniaplanet.com/account/dedicated-servers
SERVER_PASSWORD=dedicated_password  # Mandatory : https://www.maniaplanet.com/account/dedicated-servers
VALIDATION_KEY=AAAAA # Mandatory : https://www.maniaplanet.com/account/validation-code
SERVER_NAME=$f00$zMy Server Name  # Mandatory : you decide (with or without special caractere to style the text)
SERVER_COMMENT= # Optionnal : Visilble by the players
USER_PASSWORD= # Optionnal : If value then private server, else public server 
SERVER_PORT=2350 # Mandatory : to be unique
SERVER_P2P_PORT=3450 # Mandatory : to be unique
XMLRPC_PORT=5000 # Mandatory : to be unique (it will be use by ManiaControl Config file)
TITLE=TMStadium@nadeo # Mandatory : Name of the Pack
TITLE_PACK_URL=https://v4.live.maniaplanet.com/ingame/public/titles/download/TMStadium@nadeo.Title.Pack.gbx # Use https://v4.live.maniaplanet.com/ingame/public/titles/download/TITLE_PACK_FILE to have the last version of the Pack
TITLE_PACK_FILE=TMStadium@nadeo.Title.Pack.gbx # Mandatory : Same as TITLE with suffix ".Title.Pack.gbx"
CONFIG_FILE_FORCE_OVERWRITE=1 # Mandatory : If value == 1 then the config is regenerated every time the container is restarted, else the file is use as it is (you can modify it manually because the docker volume is mounted)
MATCHSETTINGS_FILE_FORCE_OVERWRITE=1 # Mandatory : If value == 1 then the Matchsettings is regenerated every time the container is restarted, else the file is use as it is (you can modify it manually because the docker volume is mounted)
MATCHSETTINGS_SCRIPT_NAME=TimeAttack.Script.txt # Mandatory : See Maniaplanet\GameData\Scripts\Modes\TrackMania (TimeAttack.Script.txt / Rounds.Script.txt / Cup.Script.txt)
MATCHSETTINGS_MAPS_FOLDER= # If value defined, all the subfolders under it (ex: value "Toto/Titi" to get the folder "UserData/Maps/Toto/Titi/"), else (empty value) all the maps on "UserData/Maps/" (including subfolders)

# ManiaControl
MANIACONTROL_CONFIG_FILE_FORCE_OVERWRITE=1 # Mandatory : If value == 1 then the config is regenerated every time the container is restarted, else the file is use as it is (you can modify it manually because the docker volume is mounted)
DEDICATED_HOST=maniaplanet_server_01 # Mandatory : name of the server container name
DEDICATED_MARIADB_HOST=maniaplanet_mariadb # Mandatory : name of the mysql/mariadb container name
DEDICATED_MARIADB_PORT=3306 # Mandatory : mysql/mariadb default port
DEDICATED_MARIADB_MANIACONTROL_USER=maniacontrol # Mandatory : mysql/mariadb login
DEDICATED_MARIADB_MANIACONTROL_PASSWORD=maniaplanet_password # Mandatory : mysql/mariadb password of the login above
DEDICATED_MARIADB_MANIACONTROL_DATABASE=maniacontrol_db # Mandatory : mysql/mariadb database name
MASTERADMIN_LOGIN= # Mandatory : Maniaplanet login that will be masteradmin 
ADMIN_LOGIN_01= # Optionnal : Others Maniaplanet login that will be masteradmin 
ADMIN_LOGIN_02= # Optionnal : Others Maniaplanet login that will be masteradmin 
```

You have to duplicate this env file and rename it with the server name you want in it (example : maniaplanet_server_01) : dedicated_vars.maniaplanet_server_01.env
I suggest to use the server login instead of "maniaplanet_server_01", it is easier to identify it.
Replace the value everywhere it appear in the docker-compose file

Docker-compose entry:

Server container (as many as you want) :
```
maniaplanet_server_01:
    container_name: maniaplanet_server_01
    build: .
    restart: always
    env_file: ./dedicated_vars.maniaplanet_server_01.env
    volumes:
        - ./UserData:/dedicated/UserData
        - ./Logs/maniaplanet_server_01:/dedicated/Logs
    expose: # visible only by the other containers (not the internet)
        - 5001
    ports: # visible by everyone (especially the internet)
        - 2351:2351
        - 2351:2351/udp
        - 3451:3451
        - 3451:3451/udp
```
For each new container, change the text "maniaplanet_server_01" (also in the ManiaControl docker configuration) and change the port number.

BDD Mysql/Mariadb use by ManiaControl container (One is enough for multiple ManiaControl) :
```
maniaplanet_mariadb:
    container_name: maniaplanet_mariadb
    image: mariadb
    restart: always
    environment:
        MYSQL_ROOT_PASSWORD: azerty  # default root => changed on first config mysql_secire_installation
    volumes:
        - ./mariadb/data:/var/lib/mysql
    expose: # visible only by the other containers (not the internet)
        - 3306 # Not mandatory (because exposed by the image) but more explicit to have the information here
```

ManiaControl container (as many as there are servers) :
```
maniaplanet_server_01_maniacontrol:
    container_name: maniaplanet_server_01_maniacontrol
    build: maniacontrol
    restart: always
    env_file: ./dedicated_vars.maniaplanet_server_01.env
    depends_on:
        - maniaplanet_mariadb
        - maniaplanet_server_01
    volumes:
        - ./maniacontrol/configs:/maniacontrol/configs
        - ./maniacontrol/logs/maniaplanet_server_01:/maniacontrol/logs
```
For each new container, change the text "maniaplanet_server_01" (Same as server docker configuration).
