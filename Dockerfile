FROM alpine:3.7
MAINTAINER Tom Valk <tomvalk@lt-box.info>

# Install several dependencies.
RUN apk update \
    && apk add --no-cache unzip wget ca-certificates \
    && ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

# Link the musl to glibc as it's compatible (required in Alpine image).
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk \
    && apk add glibc-2.25-r0.apk libstdc++ musl libuuid dos2unix

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib/:/lib/"

# Maj Jocio 2020-04-01 : Utiliser la latest pour avoir la derniere version du dedicated server
# ENV DEDICATED_URL http://files.v04.maniaplanet.com/server/ManiaplanetServer_2019-10-23.zip
ENV DEDICATED_URL http://files.v04.maniaplanet.com/server/ManiaplanetServer_Latest.zip
ENV PROJECT_DIR /dedicated
WORKDIR /dedicated

# Download dedicated + titles.
RUN wget ${DEDICATED_URL} -qO /tmp/dedicated.zip

# Create folder and unpack, cleanup, prepare executables etc.
RUN mkdir -p ${PROJECT_DIR} \
    && unzip -quo /tmp/dedicated.zip -d ${PROJECT_DIR} \
    && rm /tmp/dedicated.zip \
    && rm -rf ${PROJECT_DIR}/*.bat ${PROJECT_DIR}/*.exe ${PROJECT_DIR}/*.html ${PROJECT_DIR}/RemoteControlExamples \
    && chmod +x ${PROJECT_DIR}/ManiaPlanetServer \
    && mkdir -p ${PROJECT_DIR}/GameData \
    && mkdir -p ${PROJECT_DIR}/UserData \
    && mkdir -p ${PROJECT_DIR}/UserData/Config \
    && mkdir -p ${PROJECT_DIR}/UserData/Packs \
    && mkdir -p ${PROJECT_DIR}/UserData/Maps \
    && mkdir -p ${PROJECT_DIR}/UserData/Maps/MatchSettings

# Install the dedicated configuration file.
ADD config.default.xml ${PROJECT_DIR}/config.default.xml
RUN dos2unix ${PROJECT_DIR}/config.default.xml && chmod 775 ${PROJECT_DIR}/config.default.xml

# Install the matchsettings file.
ADD matchsettings.default.xml ${PROJECT_DIR}/matchsettings.default.xml
RUN dos2unix ${PROJECT_DIR}/matchsettings.default.xml && chmod 775 ${PROJECT_DIR}/matchsettings.default.xml

# Install run script.
ADD entrypoint.sh ${PROJECT_DIR}/start.sh
RUN dos2unix ${PROJECT_DIR}/start.sh && chmod +x ${PROJECT_DIR}/start.sh

# Expose + vols.
# VOLUME ${PROJECT_DIR}/UserData ${PROJECT_DIR}/Logs
# EXPOSE 2350 2350/udp 3450 3450/udp 5000

CMD [ "./start.sh" ]
