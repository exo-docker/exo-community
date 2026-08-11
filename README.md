# eXo Platform Community Docker image <!-- omit in toc -->

![Docker Stars](https://img.shields.io/docker/stars/exoplatform/exo-community.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/exoplatform/exo-community.svg)

The eXo Platform Community edition Docker image support `HSQLDB` (for testing) and `MySQL` (for production).

| Image                             | JDK | eXo Platform          |
|-----------------------------------|-----|-----------------------|
| exoplatform/exo-community:7.2     | 21  | 7.2 Community edition |
| exoplatform/exo-community:7.1     | 21  | 7.1 Community edition |
| exoplatform/exo-community:7.0     | 21  | 7.0 Community edition |
| exoplatform/exo-community:6.5     | 17  | 6.5 Community edition |
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
  - [JVM](#jvm)
  - [Frontend proxy](#frontend-proxy)
  - [Tomcat](#tomcat)
    - [Data on disk](#data-on-disk)
  - [Database](#database)
    - [MySQL](#mysql)
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
  - [customize some eXo Platform settings](#customize-some-exo-platform-settings)
- [Image build](#image-build)
- [Image signature](#image-signature)

## Quick start

### Easy way : with docker-compose

Follow the [quick start guide](https://docs.exoplatform.org/guide/getting-started/start-community.html#start-exo-platform)

### Advanced way : with docker images

Follow the [advanced guide](https://docs.exoplatform.org/guide/getting-started/start-community.html#start-exo-platform)

## Matrix chat

The `docker-compose.yml` file also deploys a [Matrix](https://matrix.org) messaging server (Synapse) with a PostgreSQL database, used by the eXo chat feature. The stack runs a single Synapse node over plain HTTP (no TLS, no workers).

The Synapse configuration is rendered at startup from `conf/matrix/homeserver.yaml` (a jinja2 template) using the following environment variables (default values, must be overridden beyond local testing):

| Variable | Default | Description |
|----------|---------|-------------|
| `MATRIX_SERVER_NAME` | `exoapp.local` | Synapse server name (should match `EXO_PROXY_VHOST`) |
| `MATRIX_PUBLIC_BASEURL` | `http://exoapp.local` | Public base URL of the homeserver |
| `MATRIX_ADMIN_USERNAME` | `root` | Admin account created on first startup |
| `MATRIX_ADMIN_PASSWORD` | demo value (see docker-compose.yml) | Admin account password |
| `MATRIX_DB_PASSWORD` | `matrix-secret-pw` | Synapse database user password |
| `MATRIX_POSTGRES_PASSWORD` | `matrix-super-secret-pw` | PostgreSQL superuser password |
| `MATRIX_REGISTRATION_SHARED_SECRET` | demo value (see docker-compose.yml) | Shared secret shared with eXo |
| `MATRIX_MACAROON_SECRET` | demo value (see docker-compose.yml) | Synapse macaroon secret |
| `MATRIX_FORM_SECRET` | demo value (see docker-compose.yml) | Synapse form secret |
| `MATRIX_JWT_SECRET` | demo value (see docker-compose.yml) | JWT secret shared with eXo |

These secrets are also injected into the eXo JVM via `JAVA_OPTS` (`-Dmeeds.matrix.*`), so they must stay consistent between the eXo and Matrix containers.

### Generating the secrets

Generate them from the deployment FQDN (replace `exoapp.local` with your `EXO_PROXY_VHOST`) with the following recipe: compute `sha256("<fqdn>-<salt>")`, base64-encode the raw digest, strip trailing `=`, map `/` to `A` and `+` to `B`, then keep the first N characters.

```bash
gen_secret() { local n="$1" salt="$2" fqdn="$3" seed="$fqdn-$salt" hash b64
  hash=$(printf '%s' "$seed" | sha256sum | awk '{print $1}')
  b64=$(printf '%s' "$hash" | xxd -r -p | base64 | tr -d '=' | tr '/+' 'AB')
  printf '%s' "${b64:0:$n}"
}

FQDN=exoapp.local
export MATRIX_ADMIN_PASSWORD="$(gen_secret 32 admin-password $FQDN)"
export MATRIX_REGISTRATION_SHARED_SECRET="$(gen_secret 32 reg-secret $FQDN)"
export MATRIX_MACAROON_SECRET="$(gen_secret 64 macaroon-secret $FQDN)"
export MATRIX_FORM_SECRET="$(gen_secret 32 form-secret $FQDN)"
export MATRIX_JWT_SECRET="$(gen_secret 32 jwt-secret $FQDN)"
```

Then `docker compose up -d`. Keep the `MATRIX_JWT_SECRET` at 32 characters: it is shared with eXo which signs its JWTs with the algorithm derived from the key length (`HS256` for a 32-byte key), matching the `HS256` configured on Synapse. A longer secret would make eXo sign with `HS512` and logins would fail with `JWT validation failed: unsupported_algorithm`.

`conf/matrix/.well-known/` contains the Matrix delegation files served by Nginx (`/.well-known/matrix/client` and `/.well-known/matrix/server`). If you change `EXO_PROXY_VHOST`, update these files and the `server_name`/`base_url` accordingly.

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
