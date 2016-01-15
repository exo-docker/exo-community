# eXo Platform Community Docker container

* Ubuntu
* Oracle JDK
* eXo Platform Community edition
* LibreOffice

## How to

* run the container

```
docker run -d -p 8080:8080 --name=exo exoplatform/exo-community:latest
```

* watch container logs

```
docker logs --follow exo
```

## List of available versions

* exoplatform/exo-community:4.3
   * Oracle JDK 8
   * eXo Platform 4.3.0 Community edition


* exoplatform/exo-community:4.2
  * Oracle JDK 7
  * eXo Platform 4.2.0 Community edition


* exoplatform/exo-community:4.1
  * Oracle JDK 7
  * eXo Platform 4.1.0 Community edition
