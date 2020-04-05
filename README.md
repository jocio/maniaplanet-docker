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
SERVER_NAME=$09f$zMy Server Name
LOGIN=dedicated_login
PASSWORD=dedicated_password
TITLE=TMStadium@nadeo
TITLE_PACK_URL=https://v4.live.maniaplanet.com/ingame/public/titles/download/TMStadium@nadeo.Title.Pack.gbx
TITLE_PACK_FILE=TMStadium@nadeo.Title.Pack.gbx
MATCH_SETTINGS=MatchSettings/default.txt
DEDICATED_CFG=config.dedicated_login.txt
FORCE_IP_PORT=2350
```


Docker-compose entry:

```
  dedicated:
    image: jocio/maniaplanet-dedicated
    restart: always
    env_file: ./dedicated_vars.dedicated_login.env
    volumes:
      - ./UserData:/dedicated/UserData
      - ./Logs/dedicated_login:/dedicated/Logs
    expose: # visible only by the other containers (not the internet)
      - 5000
    ports:
      - 2350:2350
      - 2350:2350/udp
      - 3450:3450
      - 3450:3450/udp
```
