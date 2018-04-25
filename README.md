# eXo Platform Community Docker image
[![Docker Stars](https://img.shields.io/docker/stars/exoplatform/exo-community.svg)]() [![Docker Pulls](https://img.shields.io/docker/pulls/exoplatform/exo-community.svg)]()

The eXo Platform Community edition Docker image support `HSQLDB` (for testing) and `MySQL` (for production).

|    Image                         |  JDK  |   eXo Platform           
|----------------------------------|-------|--------------------------
|exoplatform/exo-community:develop |   8   | 5.1 Community edition  
|exoplatform/exo-community:latest  |   8   | 5.1 Community edition  
|exoplatform/exo-community:5.1     |   8   | 5.1 Community edition  
|exoplatform/exo-community:5.0     |   8   | 5.0 Community edition  
|exoplatform/exo-community:4.4     |   8   | 4.4 Community edition  
|exoplatform/exo-community:4.3     |   8   | 4.3 Community edition  
|exoplatform/exo-community:4.2     |   7   | 4.2 Community edition  
|exoplatform/exo-community:4.1     |   7   | 4.1 Community edition  

## Quick start

The prerequisites are :
* Docker daemon version 12+ + internet access
* 4GB of available RAM + 1GB of disk


The most basic way to start eXo Platform Community edition for *evaluation* purpose is to execute
```
docker run -v exo_data:/srv/exo -p 8080:8080 exoplatform/exo-community
```
and then waiting the log line which say that the server is started
```
2017-05-22 10:49:30,176 | INFO  | Server startup in 83613 ms [org.apache.catalina.startup.Catalina<main>]
```
When ready just go to http://localhost:8080 and follow the instructions ;-)

## Configuration options

### Add-ons

Some add-ons are already installed in eXo image but you can install other one or remove some of the pre-installed one :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_ADDONS_LIST | NO | - | commas separated list of add-ons to install (ex: exo-answers,exo-skype:1.0.x-SNAPSHOT)
| EXO_ADDONS_REMOVE_LIST | NO | - | commas separated list of add-ons to uninstall (ex: exo-chat,exo-es-embedded) (since: 5.0)

### JVM

The standard eXo Platform environment variables can be used :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_JVM_SIZE_MIN | NO | `512m` | specify the jvm minimum allocated memory size (-Xms parameter)
| EXO_JVM_SIZE_MAX | NO | `3g` | specify the jvm maximum allocated memory size (-Xmx parameter)
| EXO_JVM_PERMSIZE_MAX | NO | `256m` | (Java 7) specify the jvm maximum allocated memory to Permgen (-XX:MaxPermSize parameter)
| EXO_JVM_METASPACE_SIZE_MAX | NO | `512m` | (Java 8+) specify the jvm maximum allocated memory to MetaSpace (-XX:MaxMetaspaceSize parameter)
| EXO_JVM_USER_LANGUAGE | NO | `en` | specify the jvm locale for langage (-Duser.language parameter)
| EXO_JVM_USER_REGION | NO | `US` | specify the jvm local for region (-Duser.region parameter)

INFO: This list is not exhaustive (see eXo Platform documentation or {EXO_HOME}/bin/setenv.sh for more parameters)

### Frontend proxy

The following environment variables must be passed to the container to configure Tomcat proxy settings:

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_PROXY_VHOST | NO | `localhost` | specify the virtual host name to reach eXo Platform
| EXO_PROXY_PORT | NO | - | which port to use on the proxy server ? if empty it will automatically defined regarding EXO_PROXY_SSL value (true => 443 / false => 8080)
| EXO_PROXY_SSL | NO | `false` | is ssl activated on the proxy server ? (true / false)

## Tomcat

The following environment variables can be passed to the container to configure Tomcat settings

|    VARIABLE            |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|------------------------|-------------|--------------------------|----------------
| EXO_ACCESS_LOG_ENABLED | NO | `false` | activate Tomcat access log with combine format and a daily log file rotation

### Data on disk

The following environment variables must be passed to the container in order to work :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_DATA_DIR | NO | `/srv/exo` | the directory to store eXo Platform data
| EXO_FILE_STORAGE_DIR | NO | `${EXO_DATA_DIR}/files` | the directory to store eXo Platform data
| EXO_FILE_STORAGE_RETENTION | NO | `30` | the number of days to keep deleted files on disk before definitively remove it from the disk
| EXO_UPLOAD_MAX_FILE_SIZE | NO | `200` | maximum authorized size for file upload in MB.

### Database

The following environment variables must be passed to the container in order to work :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_DB_TYPE | NO | `hsqldb` | Community edition only support hsqldb and mysql
| EXO_DB_HOST | NO | `mysql` | the host to connect to the database server
| EXO_DB_PORT | NO | `3306` | the port to connect to the database server
| EXO_DB_NAME | NO | `exo` | the name of the database / schema to use
| EXO_DB_USER | NO | `exo` | the username to connect to the database
| EXO_DB_PASSWORD | YES | - | the password to connect to the database

### MySQL

|    VARIABLE          |  MANDATORY  |   DEFAULT VALUE  |  DESCRIPTION
|----------------------|-------------|------------------|----------------
| EXO_DB_MYSQL_USE_SSL | NO          | `false`          | connecting securely to MySQL using SSL (see MySQL Connector/J documentation for useSSL parameter)

## Mongodb

The following environment variables should be passed to the container in order to work if you installed eXo Chat add-on :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_MONGO_HOST | NO | `mongo` | the hostname to connect to the mongodb database for eXo Chat 
| EXO_MONGO_PORT | NO | `27017` | the port to connect to the mongodb server
| EXO_MONGO_USERNAME | NO | - | the username to use to connect to the mongodb database (no authentification configured by default)
| EXO_MONGO_PASSWORD | NO | - | the password to use to connect to the mongodb database (no authentification configured by default)
| EXO_MONGO_DB_NAME | NO | `chat` | the mongodb database name to use for eXo Chat 

INFO: you must configure and start an external MongoDB server by yourself

## ElasticSearch

The following environment variables should be passed to the container in order to configure the search feature on an external Elastic Search server:

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_ES_EMBEDDED | NO | `true` | do we use an elasticsearch server embedded in the eXo Platform JVM or do we use an external one ? (using an embedded elasticsearch server is not recommanded for production purpose)
| EXO_ES_EMBEDDED_DATA | NO | `/srv/exo/es/` | The directory to use for storing elasticsearch data (in embedded mode only).
| EXO_ES_SCHEME | NO | `http` | the elasticsearch server scheme to use from the eXo Platform server jvm perspective (http / https).
| EXO_ES_HOST | NO | `localhost` | the elasticsearch server hostname to use from the eXo Platform server jvm perspective.
| EXO_ES_PORT | NO | `9200` | the elasticsearch server port to use from the eXo Platform server jvm perspective.
| EXO_ES_USERNAME | NO | - | the username to connect to the elasticsearch server (if authentication is activated on the external elasticsearch).
| EXO_ES_PASSWORD | NO | - | the password to connect to the elasticsearch server (if authentication is activated on the external elasticsearch).
| EXO_ES_INDEX_REPLICA_NB | NO | `0` | the number of replicat for elasticsearch indexes (leave 0 if you don't have an elasticsearch cluster).
| EXO_ES_INDEX_SHARD_NB | NO | `0` | the number of shard for elasticsearch indexes.

INFO: the default embedded ElasticSearch in not recommended for production purpose.

## Mail

The following environment variables should be passed to the container in order to configure the mail server configuration to use :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_MAIL_FROM | NO | `noreply@exoplatform.com` | "from" field of emails sent by eXo platform
| EXO_MAIL_SMTP_HOST | NO | `localhost` | SMTP Server hostname
| EXO_MAIL_SMTP_PORT | NO | `25` | SMTP Server port
| EXO_MAIL_SMTP_STARTTLS | NO | `false` | true to enable the secure (TLS) SMTP. See RFC 3207.
| EXO_MAIL_SMTP_USERNAME | NO | - | authentication username for smtp server (if needed)
| EXO_MAIL_SMTP_PASSWORD | NO | - | authentication password for smtp server (if needed)

## JMX

The following environment variables should be passed to the container in order to configure JMX :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_JMX_ENABLED | NO | `true` | activate JMX listener
| EXO_JMX_RMI_REGISTRY_PORT | NO | `10001` | JMX RMI Registry port
| EXO_JMX_RMI_SERVER_PORT | NO | `10002` | JMX RMI Server port
| EXO_JMX_RMI_SERVER_HOSTNAME | NO | `localhost` | JMX RMI Server hostname
| EXO_JMX_USERNAME | NO | - | a username for JMX connection (if no username is provided, the JMX access is unprotected)
| EXO_JMX_PASSWORD | NO | - | a password for JMX connection (if no password is specified a random one will be generated and stored in /opt/exo/conf/jmxremote.password)

With the default parameters you can connect to JMX with `service:jmx:rmi://localhost:10002/jndi/rmi://localhost:10001/jmxrmi` without authentication.

## How-to ...

### configure eXo Platform behind a reverse-proxy

You have to specify the following environment variables to configure eXo Platform (see upper section for more parameters and details) :

```
docker run -d \
    -p 8080:8080 \
    -e EXO_PROXY_VHOST="my.public-facing-hostname.org" \
    exoplatform/exo-community
```

You can also use Docker Compose (see the provided `docker-compose.yml` file as an example).

### use MySQL database

You have to specify the following environment variables to point to an external MySQL database server (see upper section for more parameters and details) :

```
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

```
docker logs --follow <CONTAINER_NAME>
```

### install eXo Platform add-ons

To install add-ons in the container, provide a commas separated list of add-ons you want to install in a `EXO_ADDONS_LIST` environment variable to the container:

```
docker run -d \
    -p 8080:8080 \
    -e EXO_ADDONS_LIST="exo-tasks:1.3.x-SNAPSHOT,exo-answers:1.3.x-SNAPSHOT" \
    exoplatform/exo-community
```

INFO: the provided add-ons list will be installed in the container during the container creation.

### list eXo Platform add-ons available

In a *running container* execute the following command:

```
docker exec <CONTAINER_NAME> /opt/exo/addon list
```

### list eXo Platform add-ons installed

In a *running container* execute the following command:

```
docker exec <CONTAINER_NAME> /opt/exo/addon list --installed
```

### customize some eXo Platform settings

As explained in [eXo Platform documentation](https://www.exoplatform.com/docs/PLF44/PLFAdminGuide.InstallationAndStartup.CustomizingEnvironmentVariables.html) you can customize several aspects of eXo platform by settings environment variables :

```
docker run -d \
    -p 8080:8080 \
    -e EXO_JVM_SIZE_MAX="8g" \
    exoplatform/exo-community
```

# Image build

The simplest way to build this image is to use default values :

    docker build -t exoplatform/exo-community .

This will produce an image with the current eXo Platform Community edition.

The build can be customized with the following arguments :

|    ARGUMENT NAME    |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| ADDONS | NO | `exo-chat exo-tasks:1.1.0 exo-jdbc-driver-mysql:1.1.0` | a space separated list of add-ons to install (default: exo-jdbc-driver-mysql:1.1.0)
