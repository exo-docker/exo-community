# Ubuntu + Oracle jdk 7 + eXo Platform Community Docker container

* Ubuntu 14.04
* Oracle JDK 7 update 60
* eXo Platform 4.1-M2 Community edition

## How to

* run the container


    docker run -d -p 8080:8080 -name="exo" exoplatform/ubuntu-jdk7-exo:plf-4.1-m2

* watch container logs


    docker logs --follow exo
