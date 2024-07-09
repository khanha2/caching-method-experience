Start postgres

Create Elastic network

```bash
docker network create elastic
```

Start elasticsearch

```bash
docker run -d --name elastic-71722 -p 19200:9200 -e "discovery.type=single-node" -e "xpack.security.enabled=true" --net elastic -e "ELASTIC_PASSWORD=changeme" elasticsearch:7.17.22
```

Start kibana

```bash
docker run -d --name kibana-71722 --net elastic -p 15601:5601 -e "ELASTICSEARCH_HOSTS=http://elastic-71722:9200" -e "ELASTICSEARCH_USERNAME=elastic" -e "ELASTICSEARCH_PASSWORD=changeme" kibana:7.17.22
```
