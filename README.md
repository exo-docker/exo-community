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
  - [JOD Converter](#jod-converter)
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

Running the eXo Platform Community edition container requires additional components to run  :

- Database (mysql or psql)
- Elastic Search
- Mongodb

These components are not provided within the docker image exoplatform/exo-community.

In order to run all components at once, we provide a Docker Compose file and
a [quick start guide](https://docs.exoplatform.org/guide/getting-started/start-community.html#start-exo-platform). It will allow you to start all
components required to get up and running easily with the default configuration.

### Advanced way : with docker images

Alternatively, you may want to run each component separately with containers. Required images are :

- [Mongo](https://hub.docker.com/_/mongo) 4.4
- [eXo Platform Elastic Search](https://hub.docker.com/r/exoplatform/elasticsearch) 2.0.3. This image is build by eXo with all
  needed ES addons
- [eXo Platform Community](https://hub.docker.com/r/exoplatform/exo-community) 6.3

To do this, you can use properties described in this document to configure eXo Community docker image.

The prerequisites are :

- Docker daemon version 12+ + internet access
- 4GB of available RAM + 1GB of disk

The most basic way to start eXo Platform Community edition for *evaluation* purpose is to execute

```bash
docker network create -d bridge exo-network
docker run -v mongo_data:/data/db -p 27017:27017 --name mongo --network=exo-network mongo:4.4
docker run -e ES_JAVA_OPTS="-Xms2048m -Xmx2048m" -e node.name=exo -e cluster.name=exo -e cluster.initial_master_nodes=exo -e network.host=_site_ -v search_data:/usr/share/elasticsearch/data --name es --network=exo-network exoplatform/elasticsearch:2.0.3
docker run -v exo_data:/srv/exo -p 8080:8080 -e EXO_ES_HOST=es --name exo --network=exo-network exoplatform/exo-community:6.3
```

and then waiting the log line which say that the server is started

```log
2017-05-22 10:49:30,176 | INFO  | Server startup in 83613 ms [org.apache.catalina.startup.Catalina<main>]
```

When ready just go to <http://localhost:8080> and follow the instructions ;-)

Once containers successfully start, you can stop/start them with
```bash
docker stop $CONTAINER_NAME
docker start $CONTAINER_NAME
```

## Configuration options

### Add-ons

Some add-ons are already installed in eXo image but you can install other one or remove some of the pre-installed one :

| VARIABLE                 | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                   |
| ------------------------ | --------- | ------------- | --------------------------------------------------------------------------------------------- |
| EXO_ADDONS_LIST          | NO        | -             | commas separated list of add-ons to install (ex: exo-answers,exo-skype:1.0.x-SNAPSHOT)        |
| EXO_ADDONS_REMOVE_LIST   | NO        | -             | commas separated list of add-ons to uninstall (ex: exo-chat) (since: 4.4.2_3) |
| EXO_ADDONS_CATALOG_URL   | NO        | -             | The url of a valid eXo Catalog                                                                |
| EXO_ADDONS_CONFLICT_MODE | NO        | -             | decision to make in case of file conflicts (overwrite, ignore or fail)                        |
| EXO_ADDONS_NOCOMPAT_MODE | NO        | false         | decision to allow to install incompatible addon |                                                  |

### JVM

The standard eXo Platform environment variables can be used :

| VARIABLE                   | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                      |
|----------------------------|-----------|---------------|--------------------------------------------------------------------------------------------------|
| EXO_JVM_SIZE_MIN           | NO        | `512m`        | specify the jvm minimum allocated memory size (-Xms parameter)                                   |
| EXO_JVM_SIZE_MAX           | NO        | `3g`          | specify the jvm maximum allocated memory size (-Xmx parameter)                                   |
| EXO_JVM_PERMSIZE_MAX       | NO        | `256m`        | (Java 7) specify the jvm maximum allocated memory to Permgen (-XX:MaxPermSize parameter)         |
| EXO_JVM_METASPACE_SIZE_MAX | NO        | `512m`        | (Java 8+) specify the jvm maximum allocated memory to MetaSpace (-XX:MaxMetaspaceSize parameter) |
| EXO_JVM_USER_LANGUAGE      | NO        | `en`          | specify the jvm locale for langage (-Duser.language parameter)                                   |
| EXO_JVM_USER_REGION        | NO        | `US`          | specify the jvm local for region (-Duser.region parameter)                                       |
| EXO_JVM_LOG_GC_ENABLED     | NO        | `false`       | activate the JVM GC log file generation (location: $EXO_LOG_DIR/platform-gc.log) (5.1.0-RC12+)   |

INFO: This list is not exhaustive (see eXo Platform documentation or {EXO_HOME}/bin/setenv.sh for more parameters)

### Frontend proxy

The following environment variables must be passed to the container to configure Tomcat proxy settings:

| VARIABLE        | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                                                                |
|-----------------|-----------|---------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| EXO_PROXY_VHOST | NO        | `localhost`   | specify the virtual host name to reach eXo Platform                                                                                        |
| EXO_PROXY_PORT  | NO        | -             | which port to use on the proxy server ? if empty it will automatically defined regarding EXO_PROXY_SSL value (true => 443 / false => 8080) |
| EXO_PROXY_SSL   | NO        | `false`       | is ssl activated on the proxy server ? (true / false)                                                                                      |

### Tomcat

The following environment variables can be passed to the container to configure Tomcat settings

| VARIABLE               | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                  |
|------------------------|-----------|---------------|------------------------------------------------------------------------------|
| EXO_HTTP_THREAD_MAX    | NO        | `200`         | maximum number of threads in the tomcat http connector                       |
| EXO_HTTP_THREAD_MIN    | NO        | `10`          | minimum number of threads ready in the tomcat http connector                 |
| EXO_ACCESS_LOG_ENABLED | NO        | `false`       | activate Tomcat access log with combine format and a daily log file rotation |
| EXO_GZIP_ENABLED       | NO        | `true`        | activate Tomcat Gzip compression for assets mimetypes          
#### Data on disk

The following environment variables must be passed to the container in order to work :

| VARIABLE                   | MANDATORY | DEFAULT VALUE                | DESCRIPTION                                                                                           |
| -------------------------- | --------- | ---------------------------- | ------------------------------------------------------------------------------------------------------|
| EXO_DATA_DIR               | NO        | `/srv/exo`                   | the directory to store eXo Platform data                                                              |
| EXO_JCR_STORAGE_DIR        | NO        | `${EXO_DATA_DIR}/jcr/values` | the directory to store eXo Platform JCR values data                                                   |
| EXO_JCR_FS_STORAGE_ENABLED | NO        | Default value of eXo Server  | Whether to store JCR Binary files in RDBMS or File system. Possible values: true (=FS) OR false (=DB) |
| EXO_FILE_STORAGE_DIR       | NO        | `${EXO_DATA_DIR}/files`      | the directory to store eXo Platform data                                                              |
| EXO_FILE_STORAGE_TYPE      | NO        | Default value of eXo Server  | Whether to store Files API Binary files in RDBMS or File system. Possible values: rdbms OR fs         |
| EXO_FILE_STORAGE_RETENTION | NO        | `30`                         | the number of days to keep deleted files on disk before definitively remove it from the disk          |
| EXO_UPLOAD_MAX_FILE_SIZE   | NO        | `200`                        | maximum authorized size for file upload in MB.                                                        |
| EXO_FILE_UMASK             | NO        | `0022`                       | the umask used for files generated by eXo                                                             |
                                                  |

### Database

The following environment variables must be passed to the container in order to work :

| VARIABLE                  | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                           |
|---------------------------|-----------|---------------|---------------------------------------------------------------------------------------|
| EXO_DB_TYPE               | NO        | `hsqldb`      | Community edition only support hsqldb and mysql                                       |
| EXO_DB_HOST               | NO        | `mysql`       | the host to connect to the database server                                            |
| EXO_DB_PORT               | NO        | `3306`        | the port to connect to the database server                                            |
| EXO_DB_NAME               | NO        | `exo`         | the name of the database / schema to use                                              |
| EXO_DB_USER               | NO        | `exo`         | the username to connect to the database                                               |
| EXO_DB_PASSWORD           | YES       | -             | the password to connect to the database                                               |
| EXO_DB_POOL_IDM_INIT_SIZE | NO        | `5`           | the init size of IDM datasource pool                                                  |
| EXO_DB_POOL_IDM_MAX_SIZE  | NO        | `20`          | the max size of IDM datasource pool                                                   |
| EXO_DB_POOL_JCR_INIT_SIZE | NO        | `5`           | the init size of JCR datasource pool                                                  |
| EXO_DB_POOL_JCR_MAX_SIZE  | NO        | `20`          | the max size of JCR datasource pool                                                   |
| EXO_DB_POOL_JPA_INIT_SIZE | NO        | `5`           | the init size of JPA datasource pool                                                  |
| EXO_DB_POOL_JPA_MAX_SIZE  | NO        | `20`          | the max size of JPA datasource pool                                                   |
| EXO_DB_TIMEOUT            | NO        | `60`          | the number of seconds to wait for database availability before cancelling eXo startup |

#### MySQL

| VARIABLE             | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                       |
|----------------------|-----------|---------------|---------------------------------------------------------------------------------------------------|
| EXO_DB_MYSQL_USE_SSL | NO        | `false`       | connecting securely to MySQL using SSL (see MySQL Connector/J documentation for useSSL parameter) |

### Mongodb

The following environment variables should be passed to the container in order to work if you installed eXo Chat add-on :

| VARIABLE           | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                        |
|--------------------|-----------|---------------|----------------------------------------------------------------------------------------------------|
| EXO_MONGO_HOST     | NO        | `mongo`       | the hostname to connect to the mongodb database for eXo Chat                                       |
| EXO_MONGO_PORT     | NO        | `27017`       | the port to connect to the mongodb server                                                          |
| EXO_MONGO_USERNAME | NO        | -             | the username to use to connect to the mongodb database (no authentification configured by default) |
| EXO_MONGO_PASSWORD | NO        | -             | the password to use to connect to the mongodb database (no authentification configured by default) |
| EXO_MONGO_DB_NAME  | NO        | `chat`        | the mongodb database name to use for eXo Chat                                                      |
| EXO_MONGO_TIMEOUT  | NO        | `60`          | the number of seconds to wait for mongodb availability before cancelling eXo startup               |

INFO: you must configure and start an external MongoDB server by yourself

### ElasticSearch
The following environment variables should be passed to the container in order to configure the search feature :

| VARIABLE                | MANDATORY | DEFAULT VALUE  | DESCRIPTION                                                                                                                                                                                                                                                                    |
| ----------------------- | --------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| EXO_ES_SCHEME           | NO        | `http`         | the elasticsearch server scheme to use from the eXo Platform server jvm perspective (http / https).                                                                                                                                                                            |
| EXO_ES_HOST             | NO        | `localhost`    | the elasticsearch server hostname to use from the eXo Platform server jvm perspective.                                                                                                                                                                                         |
| EXO_ES_PORT             | NO        | `9200`         | the elasticsearch server port to use from the eXo Platform server jvm perspective.                                                                                                                                                                                             |
| EXO_ES_USERNAME         | NO        | -              | the username to connect to the elasticsearch server (if authentication is activated on the external elasticsearch).                                                                                                                                                            |
| EXO_ES_PASSWORD         | NO        | -              | the password to connect to the elasticsearch server (if authentication is activated on the external elasticsearch).                                                                                                                                                            |
| EXO_ES_INDEX_REPLICA_NB | NO        | `0`            | the number of replicat for elasticsearch indexes (leave 0 if you don't have an elasticsearch cluster).                                                                                                                                                                         |
| EXO_ES_INDEX_SHARD_NB   | NO        | `0`            | the number of shard for elasticsearch indexes.                                                                                                                                                                                                                                 |
| EXO_ES_TIMEOUT          | NO        | `60`           | the number of seconds to wait for elasticsearch availability before cancelling eXo startup                                                                                        
### LDAP / Active Directory

The following environment variables should be passed to the container in order to configure the ldap connection pool :

| VARIABLE               | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                                                                  |
| ---------------------- | --------- | ------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| EXO_LDAP_POOL_DEBUG    | NO        | -             | the level of debug output to produce. Valid values are "fine" (trace connection creation and removal) and "all" (all debugging information). |
| EXO_LDAP_POOL_TIMEOUT  | NO        | `60000`       | the number of milliseconds that an idle connection may remain in the pool without being closed and removed from the pool.                    |
| EXO_LDAP_POOL_MAX_SIZE | NO        | `100`         | the maximum number of connections per connection identity that can be maintained concurrently.                                               |

### JOD Converter

The following environment variables should be passed to the container in order to configure jodconverter :

| VARIABLE               | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                               |
|------------------------|-----------|---------------|-------------------------------------------------------------------------------------------|
| EXO_JODCONVERTER_PORTS | NO        | `2002`        | comma separated list of ports to allocate to JOD Converter processes (ex: 2002,2003,2004) |

### Mail

The following environment variables should be passed to the container in order to configure the mail server configuration to use :

| VARIABLE               | MANDATORY | DEFAULT VALUE             | DESCRIPTION                                         |
|------------------------|-----------|---------------------------|-----------------------------------------------------|
| EXO_MAIL_FROM          | NO        | `noreply@exoplatform.com` | "from" field of emails sent by eXo platform         |
| EXO_MAIL_SMTP_HOST     | NO        | `localhost`               | SMTP Server hostname                                |
| EXO_MAIL_SMTP_PORT     | NO        | `25`                      | SMTP Server port                                    |
| EXO_MAIL_SMTP_STARTTLS | NO        | `false`                   | true to enable the secure (TLS) SMTP. See RFC 3207. |
| EXO_MAIL_SMTP_USERNAME | NO        | -                         | authentication username for smtp server (if needed) |
| EXO_MAIL_SMTP_PASSWORD | NO        | -                         | authentication password for smtp server (if needed) |
| EXO_SMTP_SSL_PROTOCOLS | NO        | -                         | tls version for smtp server (if needed) |


### JMX

The following environment variables should be passed to the container in order to configure JMX :

| VARIABLE                    | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                                                               |
|-----------------------------|-----------|---------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| EXO_JMX_ENABLED             | NO        | `true`        | activate JMX listener                                                                                                                     |
| EXO_JMX_RMI_REGISTRY_PORT   | NO        | `10001`       | JMX RMI Registry port                                                                                                                     |
| EXO_JMX_RMI_SERVER_PORT     | NO        | `10002`       | JMX RMI Server port                                                                                                                       |
| EXO_JMX_RMI_SERVER_HOSTNAME | NO        | `localhost`   | JMX RMI Server hostname                                                                                                                   |
| EXO_JMX_USERNAME            | NO        | -             | a username for JMX connection (if no username is provided, the JMX access is unprotected)                                                 |
| EXO_JMX_PASSWORD            | NO        | -             | a password for JMX connection (if no password is specified a random one will be generated and stored in /opt/exo/conf/jmxremote.password) |

With the default parameters you can connect to JMX with `service:jmx:rmi://localhost:10002/jndi/rmi://localhost:10001/jmxrmi` without authentication.

### Remote Debugging

The following environment variables should be passed to the container in order to enable remote debugging mode :

| VARIABLE                    | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                                                               |
| --------------------------- | --------- | ------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| EXO_DEBUG_ENABLED           | NO        | `false`       | enable remote debugging listener                                                                                                                     |
| EXO_DEBUG_PORT              | NO        | `8000`        | Remote debugging port

### Rememberme Token Expiration

The following environment variables should be passed to the container in order to specify rememberme token expiration :

| VARIABLE                                        | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                                                               |
| ------------------------------------------------| --------- | ------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| EXO_TOKEN_REMEMBERME_EXPIRATION_VALUE           | NO        | `7`          | Number of unit expiration delay                                                                                                                     |
| EXO_TOKEN_REMEMBERME_EXPIRATION_UNIT            | NO        | `DAY`        | Unit of token expiration `DAY`, `HOUR`, `MINUTE`, `SECOND`

### Reward Wallet

The following environment variables should be passed to the container in order to configure eXo Rewards wallet:

| VARIABLE                                      | MANDATORY | DEFAULT VALUE                                                    | DESCRIPTION                                                                                                                                                                                                                       |
|-----------------------------------------------|-----------|------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| EXO_REWARDS_WALLET_ADMIN_KEY                  | YES       | `changeThisKey`                                                  | password used to encrypt the Admin wallet’s private key stored in database. If its value is modified after server startup, the private key of admin wallet won’t be decrypted anymore, preventing all administrative operations   |
| EXO_REWARDS_WALLET_ADMIN_PRIVATE_KEY                  | NO       |                                                  | Admin wallet's private key. When set, it allows to apply an existant admin wallet in the new created instance |
| EXO_REWARDS_WALLET_ACCESS_PERMISSION          | NO        | `/platform/users`                                                | to restrict access to wallet application to a group of users (ex: member:/spaces/internal_space)                                                                                                                                  |
| EXO_REWARDS_WALLET_NETWORK_ID                 | NO        | `1` (mainnet)                                                    | ID of the Ethereum network to use (see: <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md#list-of-chain-ids>)                                                                                                         |
| EXO_REWARDS_WALLET_NETWORK_ENDPOINT_HTTP      | NO        | `https://mainnet.infura.io/v3/a1ac85aea9ce4be88e9e87dad7c01d40`  | https url to access to the Ethereum API for the chosen network id                                                                                                                                                                 |
| EXO_REWARDS_WALLET_NETWORK_ENDPOINT_WEBSOCKET | NO        | `wss://mainnet.infura.io/ws/v3/a1ac85aea9ce4be88e9e87dad7c01d40` | wss url to access to the Ethereum API for the chosen network id                                                                                                                                                                   |
| EXO_REWARDS_WALLET_TOKEN_ADDRESS              | NO        | `0xc76987d43b77c45d51653b6eb110b9174acce8fb`                     | address of the contract for the official rewarding token promoted by eXo                                                                                                                                                         | 
| EXO_REWARDS_WALLET_NETWORK_CRYPTOCURRENCY              | NO        |                     | When not set, the cryptocurrency is got from the contract   |
| EXO_REWARDS_WALLET_TOKEN_SYMBOL              | NO        |                     | When not set, the token's symbol is got from the contract   |
                                                                                                 |
### Agenda

The following environment variables should be passed to the container in order to configure eXo Agenda remote connectors:

| VARIABLE                                      | MANDATORY | DEFAULT VALUE  | DESCRIPTION                                                                                                                                                                                                                                                                                                                              |
|-----------------------------------------------|-----------|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| EXO_AGENDA_GOOGLE_CONNECTOR_ENABLED           | NO        | `true`         | Whether to enable or not users to connect their personal Agenda to eXo Agenda or not.                                                                                                                                                                                                                                                    |
| EXO_AGENDA_GOOGLE_CONNECTOR_CLIENT_API_KEY    | NO        |                | This Client API key has to be provided when turning `on` Google Remote Connector for users. In fact, the users requests to google account will use this key to be able to retrieve information from their account. ( See https://developers.google.com/calendar/auth )                                                                   |
| EXO_AGENDA_OFFICE_CONNECTOR_ENABLED           | NO        | `true`         | Whether to enable or not users to connect their personal Agenda to eXo Agenda or not.                                                                                                                                                                                                                                                    |
| EXO_AGENDA_OFFICE_CONNECTOR_CLIENT_API_KEY    | NO        |                | This Client API key has to be provided when turning `on` Office Remote Connector for users. In fact, the users requests to Office 365 Outlook account will use this key to be able to retrieve information from their account. ( See https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-client-creds-grant-flow ) |

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
cosign verify --key cosign.pub ghcr.io/exo-docker/exo-community:6.3
```
  Output:
```json
[{"critical":{"identity":{"docker-reference":"ghcr.io/exo-docker/exo-community"},"image":{"docker-manifest-digest":"sha256:cb490a56d23b940fc166329dbf243dc73d2651c8a64399413e1c23e14284f6a3"},"type":"cosign container image signature"},"optional":null}]

```
