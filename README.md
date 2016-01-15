# eXo Platform Community Docker container

* Ubuntu 14.04
* Oracle JDK 7
* eXo Platform 4.1.0 Community edition

## How to

* run the container

```
docker run -d -p 8080:8080 --name=exo exoplatform/exo-community:4.1
```

* watch container logs

```
docker logs --follow exo
```
