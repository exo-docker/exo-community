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

* customize some eXo Platform settings

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

|    Image                        |  JDK  |   eXo Platform
|---------------------------------|-------|--------------------------
|exoplatform/exo-community:latest |   8   | 4.3.0 Community edition
|exoplatform/exo-community:4.3    |   8   | 4.3.0 Community edition
|exoplatform/exo-community:4.2    |   7   | 4.2.0 Community edition
|exoplatform/exo-community:4.1    |   7   | 4.1.0 Community edition
