# eXo Platform Community Docker image <!-- omit in toc -->

![Docker Stars](https://img.shields.io/docker/stars/exoplatform/exo-community.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/exoplatform/exo-community.svg)

The eXo Platform Community edition Docker image support `HSQLDB` (for testing) and `MySQL` (for production).

| Image                             | JDK | eXo Platform          |
|-----------------------------------|-----|-----------------------|
| exoplatform/exo-community:6.4     | 17  | 6.4 Community edition |
| exoplatform/exo-community:6.3     | 11  | 6.3 Community edition |
| exoplatform/exo-community:5.3     | 8   | 5.3 Community edition |
| exoplatform/exo-community:5.2     | 8   | 5.2 Community edition |
| exoplatform/exo-community:5.1     | 8   | 5.1 Community edition |
| exoplatform/exo-community:5.0     | 8   | 5.0 Community edition |
| exoplatform/exo-community:4.4     | 8   | 4.4 Community edition |
| exoplatform/exo-community:4.3     | 8   | 4.3 Community edition |
| exoplatform/exo-community:4.2     | 7   | 4.2 Community edition |
| exoplatform/exo-community:4.1     | 7   | 4.1 Community edition |

The image is compatible with the following databases system :  `MySQL` (default) / `HSQLDB` / `PostgreSQL`

- [Quick start](#quick-start)
  - [Easy way](#easy-way--with-docker-compose)
  - [Advanced way](#advanced-way--with-docker-images)
- [Configuration options](#configuration-options)
  - [Add-ons](#add-ons)
  - [JVM](#jvm)
  - [Frontend proxy](#frontend-proxy)
  - [Tomcat](#tomcat)
    - [Data on disk](#data-on-disk)
  - [Database](#database)
    - [MySQL](#mysql)
  - [Mongodb](#mongodb)
  - [ElasticSearch](#elasticsearch)
  - [LDAP / Active Directory](#ldap--active-directory)
  - [Mail](#mail)
  - [JMX](#jmx)
  - [Remote Debugging](#remote-debugging)
  - [Rememberme Token Expiration](#rememberme-token-expiration)
  - [Reward Wallet](#reward-wallet)
  - [Agenda](#agenda)
- [How-to](#how-to)
  - [configure eXo Platform behind a reverse-proxy](#configure-exo-platform-behind-a-reverse-proxy)
  - [use MySQL database](#use-mysql-database)
  - [see eXo Platform logs](#see-exo-platform-logs)
  - [install eXo Platform add-ons](#install-exo-platform-add-ons)
  - [list eXo Platform add-ons available](#list-exo-platform-add-ons-available)
  - [list eXo Platform add-ons installed](#list-exo-platform-add-ons-installed)
  - [customize some eXo Platform settings](#customize-some-exo-platform-settings)
- [Image build](#image-build)
- [Image signature](#image-signature)

## Quick start

### Easy way : with docker-compose

Follow the [quick start guide](https://docs.exoplatform.org/guide/getting-started/start-community.html#start-exo-platform)

### Advanced way : with docker images

Follow the [advanced guide](https://docs.exoplatform.org/guide/getting-started/start-community.html#start-exo-platform)

## Configuration options

Configuration options are available [here](https://github.com/exo-docker/exo-community/blob/master/configuration.md) 


## How-to

### configure eXo Platform behind a reverse-proxy

You have to specify the following environment variables to configure eXo Platform (see upper section for more parameters and details) :

```bash
docker run -d \
  -p 8080:8080 \
  -e EXO_PROXY_VHOST="my.public-facing-hostname.org" \
  exoplatform/exo-community
```

You can also use Docker Compose (see the provided `docker-compose.yml` file as an example).

### use MySQL database

You have to specify the following environment variables to point to an external MySQL database server (see upper section for more parameters and details) :

```bash
docker run -d \
  -p 8080:8080 \
  -e EXO_DB_TYPE="mysql" \
  -e EXO_DB_HOST="mysql.server-hostname.org" \
  -e EXO_DB_USER="exo" \
  -e EXO_DB_PASSWORD="my-secret-pw" \
  exoplatform/exo-community
```

You can also use Docker Compose (see the provided `docker-compose.yml` file as an example).

### see eXo Platform logs

```bash
docker logs --follow <CONTAINER_NAME>
```

### install eXo Platform add-ons

To install add-ons in the container, provide a commas separated list of add-ons you want to install in a `EXO_ADDONS_LIST` environment variable to the container:

```bash
docker run -d \
  -p 8080:8080 \
  -e EXO_ADDONS_LIST="exo-tasks:3.4.x-SNAPSHOT" \
  exoplatform/exo-community
```

INFO: the provided add-ons list will be installed in the container during the container creation.

### list eXo Platform add-ons available

In a *running container* execute the following command:

```bash
docker exec <CONTAINER_NAME> /opt/exo/addon list
```

### list eXo Platform add-ons installed

In a *running container* execute the following command:

```bash
docker exec <CONTAINER_NAME> /opt/exo/addon list --installed
```

### customize some eXo Platform settings

All previously mentioned [environment variables](#configuration-options) can be defined in a standard Docker way with `-e ENV_VARIABLE="value"` parameters :

```bash
docker run -d \
  -p 8080:8080 \
  -e EXO_JVM_SIZE_MAX="8g" \
  exoplatform/exo-community
```

Some [eXo configuration properties](https://docs.exoplatform.org/administration/configuration.html) can also be defined in an `exo.properties` file (starting from exoplatform/exo-community:5.1 version). In this case, just create this file and bind mount it in the Docker container :

```bash
docker run -d \
  -p 8080:8080 \
  -v /absolute/path/to/exo.properties:/etc/exo/exo.properties:ro \
  exoplatform/exo-community
```

## Image build

The simplest way to build this image is to use default values :

    docker build -t exoplatform/exo-community .

This will produce an image with the current eXo Platform Community edition.

The build can be customized with the following arguments :

| ARGUMENT NAME | MANDATORY | DEFAULT VALUE                                          | DESCRIPTION                                                                         |
|---------------|-----------|--------------------------------------------------------|-------------------------------------------------------------------------------------|
| ADDONS        | NO        | `exo-chat exo-tasks:1.1.0 exo-jdbc-driver-mysql:1.1.0` | a space separated list of add-ons to install (default: exo-jdbc-driver-mysql:1.1.0) |

## Image Signature

:octocat: ghcr.io Docker image signature
========================================

Starting with eXo Community `6.3` from the github container registry, eXo Community docker images will be signed with [cosign] (https://github.com/sigstore/cosign) tool.

In order to verify the signature of the eXo Community docker image, please install the "cosign" command line tool. Then please follow these instructions:

- Save the following public key to `cosign.pub` file:
```gpg
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEgYKR7SoWbXjHya1Bc2Ih3kX8wv8w
Y7StaVsRXzbcIL0jECiKzKarPxQQ69uVmZ6c0JEVQhBeN9w3pr75D4o2/A==
-----END PUBLIC KEY-----
```
- Execute the following command:
```bash
cosign verify --key cosign.pub ghcr.io/exo-docker/exo-community:<tag>
```
*Example:*
```bash
cosign verify --key cosign.pub ghcr.io/exo-docker/exo-community:6.4
```
  Output:
```json
[{"critical":{"identity":{"docker-reference":"ghcr.io/exo-docker/exo-community"},"image":{"docker-manifest-digest":"sha256:906afd0b16900e9ba...."},"type":"cosign container image signature"},"optional":{"Bundle":{"SignedEntryTimestamp":"MEQCIGtU3...","Payload":{"body":"eyJhcGlWZX....","integratedTime":1689844562,"logIndex":28114552,"logID":"c0d23d6..."}}}}]
```
