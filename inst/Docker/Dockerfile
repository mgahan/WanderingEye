
FROM rocker/tidyverse

## Maintainer
MAINTAINER "Mike Gahan" michael.gahan@gmail.com

## Make script run in non-interactive mode
ENV DEBIAN_FRONTEND noninteractive

## Document last time updated
ENV LAST_UPDATE=2017-10-04

## Update & upgrade
RUN apt-get update && \
    apt-get upgrade -y

# AWS CLI needs the PYTHONIOENCODING environment varialbe to handle UTF-8 correctly:
# https://hub.docker.com/r/fstab/aws-cli/
ENV PYTHONIOENCODING=UTF-8

# Set directory
WORKDIR /root/

# Install dependencies
RUN apt-get install -y \
    less \
    man \
    python \
    python-pip \
    python-virtualenv \
    nano \
    lzop \
    openssl \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    nano \
    curl \
    p7zip-full \
    aptitude \
    pigz

## Install more dependencies
RUN aptitude -y install libgdal-dev 
RUN aptitude -y install libproj-dev
RUN r -e 'install.packages("rgdal")'
RUN r -e 'install.packages("rgeos")'

## RUN \
RUN pip install awscli

## Install ruby
RUN apt-get -y install ruby-full

## Install more R packages
RUN r -e 'install.packages("data.table")'
RUN r -e 'install.packages("RCurl")'

# Set timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# So nano and top work
RUN export TERM=xterm

## Add WanderingEye package
ADD WanderingEye /root/WanderingEye/
RUN rm /root/WanderingEye/ENV_VARS.R /root/WanderingEye/test.R
WORKDIR /root/
RUN R CMD INSTALL --no-multiarch --with-keep.source WanderingEye

# Start servers
CMD ["/init"]

# Build
# docker build -t mgahan/wanderingeye:latest .
# docker run -it --rm mgahan/wanderingeye:latest /bin/bash
# DATE=20171004
# docker tag mgahan/wanderingeye:latest mgahan/wanderingeye:$DATE
# docker login --username=mgahan
# docker push mgahan/wanderingeye:latest
# docker push mgahan/wanderingeye:$DATE
