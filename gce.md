# How to run?

## Getting started

Welcome to the eXo Community Edition Startup tutorial. Here we will show you how to run eXo in a few steps. To get started, click on Start!

## VM Setup
Elasticsearch uses a mmapfs directory by default to store its indices. The default operating system limits on mmap counts are likely to be too low, which may result in out-of-memory exceptions. See [doc](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html).
```bash
sudo sysctl -w vm.max_map_count=262144
```
## Start eXo CE
```bash
docker-compose -f docker-compose-gce.yml -p demo up -d
docker-compose -f docker-compose-gce.yml -p demo logs -f exo
```

Wait for eXo Server's startup. A log message should appear:
```
| INFO  | Server startup in [XXXXX] milliseconds [org.apache.catalina.startup.Catalina<main>]
```
After eXo Server startup. Click on `Web preview` <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Button and click on `Preview on Port 8080`. Enjoy!

## Stop eXo CE
Hope you enjoyed our eXo Community Edition. You can tear down the server by following one of these options:
 - To stop eXo without removing docker containers:
    ```bash
    docker-compose -f docker-compose-gce.yml -p demo stop
    ```
 - To stop eXo by removing docker containers:
    ```bash
    docker-compose -f docker-compose-gce.yml -p demo down
    ```
 - To stop eXo by removing docker containers and volumes:
    ```bash
    docker-compose -f docker-compose-gce.yml -p demo down -v
    ```
You can start again eXo Server by following the previous step.

You can check out our Github [organization](https://github.com/exoplatform) and join our [community](https://community.exoplatform.com).

That's all :)