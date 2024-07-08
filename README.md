Start postgres

Start elasticsearch

```bash
docker run -d --name elasticsearch-8.14.1 -p 19200:9200 -e "discovery.type=single-node" elasticsearch:8.14.1
```

Start kibana

```bash
docker run -d --name kibana-8.14.1 -p 15601:5601 kibana:8.14.1
```
