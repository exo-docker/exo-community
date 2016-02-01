# eXo Platform Community Docker container
[![](https://badge.imagelayers.io/exoplatform/exo-community:latest.svg)](https://imagelayers.io/?images=exoplatform/exo-community:latest 'Get your own badge on imagelayers.io')
* Ubuntu
* Oracle JDK
* eXo Platform Community edition
* LibreOffice

## How to

### run the container

```
docker run -d -p 8080:8080 --name=exo exoplatform/exo-community:latest
```

* watch container logs

```
docker logs --follow exo
```

### install eXo Platform add-ons

_(starting from 4.3 container version)_

There is 2 ways to install add-ons in the container during the startup time:

* provide a commas separated list of add-ons you want to install in a `EXO_ADDONS_LIST` environment variable to the container:

```
docker run -d -p 8080:8080 --name=exo -e EXO_ADDONS_LIST="exo-tasks:1.0.0,exo-answers" exoplatform/exo-community:latest
```

* provide the list of add-ons you want to install in a file `/etc/exo/addons-list.conf` in the container:

```
docker run -d -p 8080:8080 --name=exo -v ~/addons-list.conf:/etc/exo/addons-list.conf:ro exoplatform/exo-community:latest
```

The format of the file is :
* 1 add-on declaration per line
* 1 add-on declaration is : `ADDON_ID` or `ADDON_ID:VERSION`
* every line starting with a `#` character is treated as a comment and is ignored
* every blank line is ignored

```
# Sample add-ons-list.conf file
exo-tasks:1.0.0
#exo-chat-community:1.2.0
exo-answers
```

### list installed eXo Platform add-ons

In a running container execute the following command:

```
docker exec -ti exo /sbin/setuser exo /opt/exo/current/addon list --installed
```

### customize some eXo Platform settings

As explained in [eXo Platform documentation](https://www.exoplatform.com/docs/PLF43/PLFAdminGuide.InstallationAndStartup.CustomizingEnvironmentVariables.html) you can customize several aspects of eXo platform by settings environment variables.

You can just pass environment variables:

```
docker run -d -p 8080:8080 --name=exo -e EXO_JVM_SIZE_MAX="2g" exoplatform/exo-community:latest
```

You your own `setenv-customize.sh` file:

```
docker run -d -p 8080:8080 --name=exo -v ~/setenv-customize.sh:/opt/exo/current/bin/setenv-customize.sh:ro exoplatform/exo-community:latest
```


## List of available versions

|    Image                         |  JDK  |   eXo Platform           |  Size
|----------------------------------|-------|--------------------------|----------------
|exoplatform/exo-community:latest  |   8   | 4.3.0 Community edition  |[![](https://badge.imagelayers.io/exoplatform/exo-community:latest.svg)](https://imagelayers.io/?images=exoplatform/exo-community:latest 'Get your own badge on imagelayers.io')
|exoplatform/exo-community:develop |   8   | 4.3.0 Community edition  |[![](https://badge.imagelayers.io/exoplatform/exo-community:develop.svg)](https://imagelayers.io/?images=exoplatform/exo-community:develop 'Get your own badge on imagelayers.io')
|exoplatform/exo-community:4.3     |   8   | 4.3.0 Community edition  |[![](https://badge.imagelayers.io/exoplatform/exo-community:4.3.svg)](https://imagelayers.io/?images=exoplatform/exo-community:4.3 'Get your own badge on imagelayers.io')
|exoplatform/exo-community:4.2     |   7   | 4.2.0 Community edition  |[![](https://badge.imagelayers.io/exoplatform/exo-community:4.2.svg)](https://imagelayers.io/?images=exoplatform/exo-community:4.2 'Get your own badge on imagelayers.io')
|exoplatform/exo-community:4.1     |   7   | 4.1.0 Community edition  |[![](https://badge.imagelayers.io/exoplatform/exo-community:4.1.svg)](https://imagelayers.io/?images=exoplatform/exo-community:4.1 'Get your own badge on imagelayers.io')
