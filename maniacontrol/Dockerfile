FROM php:7.4-fpm-alpine

# Install several dependencies.
RUN apk update \
    && apk upgrade \
    && apk add git libzip-dev php7-xmlrpc

# Install php dependencies
RUN docker-php-ext-install mysqli zip

ENV PROJECT_DIR /maniacontrol
WORKDIR /maniacontrol

# Download dedicated + titles.
RUN git clone https://github.com/ManiaControl/ManiaControl.git $PROJECT_DIR

# Create folder and unpack, cleanup, prepare executables etc.
RUN mkdir -p $PROJECT_DIR \
    && rm -rf $PROJECT_DIR/*.bat $PROJECT_DIR/*.exe \
    && mkdir -p $PROJECT_DIR/configs \
    && mkdir -p $PROJECT_DIR/logs

# Install run script.
ADD ManiaControl_multi.sh $PROJECT_DIR/ManiaControl_multi.sh
RUN dos2unix $PROJECT_DIR/ManiaControl_multi.sh && chmod +x $PROJECT_DIR/ManiaControl_multi.sh && chmod +x $PROJECT_DIR/ManiaControl.php

CMD [ "./ManiaControl_multi.sh" ]
