# Huge Seller for testing query method

## Setup enviroment

### Testing evironment

**Resource**

- Number of vCPUs: 2
- Memory limi: 6 GB
- Virtual disk limit: 8 GB

**Tools and Services**

- Elixir 1.16.0
- Main database: Postgres 12.19
- Elasticsearch 7.17.22
- Elasticsearch query tool: Kibana 7.12.22

### Setup services

Start Postgres

```bash
docker run -d --name postgres-12.19 -p 15432:5432 -e "POSTGRES_HOST_AUTH_METHOD=trust" postgres:12.19
```

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

### Setup environment variables

```bash
export DATABASE_URL=postgres://postgres:[your postgres password]@[your localhost]:15432/huge_seller
export ELASTICSEARCH_URL=http://[your localhost]:19200
export ELASTICSEARCH_USERNAME=elastic
export ELASTICSEARCH_PASSWORD=[your elastic password]
```

## Migration

Migration Elasticsearch

```bash
mix run --eval "HugeSeller.Tasks.migrate_es"
```

Migrate Main Database

```bash
mix ecto.create
mix ecto.migrate
```

## Generate orders

```bash
cd apps/huge_seller
mix run priv/scripts/6_genrate_orders.ex
```

## Elasticsearch query pattern

Suppose we have an order query parameters:

```json
{
  "order_codes": "O1111,O1112",
  "store_code": "S1",
  "status": "new",
  "platform_status": "pl_new",
  "created_from": "2024-07-09T00:00:00Z",
  "created_to": "2024-07-10T00:00:00Z",
  "platform_skus": "SKU-3,SKU-4,SKU-1",
  "shipment_codes": "O1111-1,O1111-2,O1112-1",
  "shipment_type": "main",
  "shipment_warehouse_platform_code": "WP1",
  "shipment_warehouse_code": "WH1",
  "shipment_status": "new",
  "shipment_warehouse_status": "wh_new",
  "shipment_created_from": "2024-07-09T00:00:00Z",
  "shipment_created_to": "2024-07-11T00:00:00Z"
}
```

The generated Elasticsearch query:

```json
{
  "bool": {
    "filter": [
      // Filter by order code
      {
        "bool": {
          "should": [
            {
              "match_phrase": {
                "code": "O1111"
              }
            },
            {
              "match_phrase": {
                "code": "O1112"
              }
            }
          ],
          "minimum_should_match": 1
        }
      },
      // Filter by store code
      {
        "match_phrase": {
          "store_code": "S1"
        }
      },
      // Filter by order status
      {
        "match_phrase": {
          "status": "new"
        }
      },
      // Filter by platform status
      {
        "match_phrase": {
          "platform_status": "pl_new"
        }
      },
      // Filter by order created time range
      {
        "range": {
          "created_at": {
            "lt": "2024-07-10T07:00:00.000+07:00",
            "gte": "2024-07-09T07:00:00.000+07:00"
          }
        }
      },
      // Filter by platform SKUs
      {
        "bool": {
          "should": [
            {
              "match_phrase": {
                "platform_skus": "SKU-3"
              }
            },
            {
              "match_phrase": {
                "platform_skus": "SKU-4"
              }
            },
            {
              "match_phrase": {
                "platform_skus": "SKU-1"
              }
            }
          ],
          "minimum_should_match": 1
        }
      },
      // Filter by shipment codes
      {
        "nested": {
          "path": "shipments",
          "query": {
            "bool": {
              "should": [
                {
                  "match_phrase": {
                    "shipments.code": "O1111-1"
                  }
                },
                {
                  "match_phrase": {
                    "shipments.code": "O1111-2"
                  }
                },
                {
                  "match_phrase": {
                    "shipments.code": "O1112-1"
                  }
                }
              ],
              "minimum_should_match": 1
            }
          }
        }
      },
      // Filter by shipment type
      {
        "nested": {
          "path": "shipments",
          "query": {
            "match_phrase": {
              "shipments.type": "main"
            }
          }
        }
      },
      // Filter by shipment warehouse platform code
      {
        "nested": {
          "path": "shipments",
          "query": {
            "match_phrase": {
              "shipments.warehouse_platform_code": "WP1"
            }
          }
        }
      },
      {
        "nested": {
          "path": "shipments",
          "query": {
            "match_phrase": {
              "shipments.warehouse_code": "WH1"
            }
          }
        }
      },
      // Filter by shipment status
      {
        "nested": {
          "path": "shipments",
          "query": {
            "match_phrase": {
              "shipments.status": "new"
            }
          }
        }
      },
      // Filter by shipment warehouse status
      {
        "nested": {
          "path": "shipments",
          "query": {
            "match_phrase": {
              "shipments.warehouse_status": "wh_new"
            }
          }
        }
      },
      // Filter by shipment created time range
      {
        "nested": {
          "path": "shipments",
          "query": {
            "range": {
              "shipments.created_at": {
                "lt": "2024-07-11T07:00:00.000+07:00",
                "gte": "2024-07-09T07:00:00.000+07:00"
              }
            }
          }
        }
      }
    ]
  }
}
```

## Update Elasticsearch document

Update an order with specific values

```
POST orders/_update/O1111
{
  "doc": {
    "status": "status",
    "platform_status": "pl_status"
  }
}
```

Update a shipment inside an order document with specific values

```dsl
POST orders/_update/O1111
{
  "script": {
    "params": {
      "order_code": "O10000",
      "shipment_code": "O10000-1",
      "shipment_status": "packed",
      "shipment_warehouse_shipment_code": "WH-O10000-1",
      "shipment_warehouse_status": "wh_packed",
      "shipment_tracking_code": "DL-O10000-1",
      "shipment_delivery_status": "dl_new"
    },
    "source": """
      for (int i = 0; i < ctx._source.shipments.size(); i++) {
        if (ctx._source.shipments[i].code == params.shipment_code) {
          ctx._source.shipments[i].shipment.delivery_status = params.shipment_code;
          ctx._source.shipments[i].shipment.tracking_code = params.shipment_status;
          ctx._source.shipments[i].shipment.warehouse_status = params.shipment_warehouse_status;
          ctx._source.shipments[i].shipment.warehouse_shipment_code = params.shipment_warehouse_shipment_code;
          ctx._source.shipments[i].shipment.status = params.shipment_status;
        }
      }
      """
  }
}
```

## References

Update Elasticsearch document:

https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update.html
