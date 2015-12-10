################################################################################
# Dockerfile to build dockerized uchiwa image
# 
# Based on: FROM debian:jessie
#
# Created On: Nov 23, 2015
# Author: Baruch Steinberg <baruch.steinberg@gmail.com>
#
# Description:
# ------------------------------------------------------------------------------
# Image include the following services/applications:
# - 
################################################################################

## Set the base image
FROM debian:jessie

## File maintainer
MAINTAINER Baruch Steinberg <baruch.steinberg@gmail.com>

###############################################################################
#
# INSTALLATION
#
################################################################################
WORKDIR /tmp

ENV DEBIAN_FRONTEND noninteractive

## Install dependencies: curl, ca-certificates
## -----------------------------------------------------------------------------
RUN apt-get update \
	&& apt-get -y install curl ca-certificates git nodejs npm --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

## Install dependencies: Go Lang
## -----------------------------------------------------------------------------
RUN curl -sSLo /tmp/go1.5.2.linux-amd64.tar.gz https://storage.googleapis.com/golang/go1.5.2.linux-amd64.tar.gz \
	&& tar -C /usr/local -xzf go1.5.2.linux-amd64.tar.gz
	
## Install dependencies: Build Essential
## -----------------------------------------------------------------------------
RUN apt-get update \
	&& apt-get -y install build-essential \
	&& rm -rf /var/lib/apt/lists/*
	
## Install Supervisord
## -----------------------------------------------------------------------------
RUN apt-get update \
	&& apt-get install -y supervisor \
    && rm -rf /var/lib/apt/lists/*

################################################################################
#
# CONFIGURATION
# 
################################################################################
ENV GOPATH /usr/local/uchiwa/go
ENV PATH $PATH:$GOPATH/bin
RUN mkdir -p /usr/local/uchiwa/go
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN /usr/local/go/bin/go get github.com/tools/godep
RUN /usr/local/go/bin/go get github.com/sensu/uchiwa && cd $GOPATH/src/github.com/sensu/uchiwa 

COPY config/package.json /tmp/package.json
COPY config/bower.json /tmp/bower.json
RUN npm install --production --unsafe-perm

RUN mkdir /config
COPY config/config.json /config/config.json

## GO Path configuraiton 
## -----------------------------------------------------------------------------
ENV PATH $PATH:/usr/local/go/bin

## Configure Supervisord 
## -----------------------------------------------------------------------------
RUN mkdir -p /etc/supervisor/conf.d/
RUN mkdir -p /var/log/supervisor
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf


################################################################################
#
# RUN
# 
################################################################################
WORKDIR /

#CMD ["/go/bin/app", "-c", "/config/config.json"]
CMD ["/usr/bin/supervisord"]

## Expose ports 
## -----------------------------------------------------------------------------
EXPOSE 3000