# alias HugeSeller.ElasticCluster
alias HugeSeller.ElasticClusterIndex

alias HugeSeller.Repository

alias HugeSeller.Usecase.BuildOrderEsQuery
alias HugeSeller.Usecase.BuildOrderQuery

orders_index = ElasticClusterIndex.orders()

IO.inspect("Retriving orders with platform status")

params = %{
  page: 1000,
  size: 100,
  platform_status: "pl_new"
}

{:ok, es_query} = BuildOrderEsQuery.perform(params)

{es_time, {:ok, es_count}} =
  :timer.tc(fn -> Repository.count_es_orders(es_query, orders_index) end)

IO.inspect("ES: retrive #{es_count} orders with execution time is #{es_time / 1_000} ms")

{:ok, pg_query} = BuildOrderQuery.perform(params)

{pg_time, pg_count} =
  :timer.tc(fn -> Repository.count_orders(pg_query) end)

IO.inspect("PG: retrive #{pg_count} orders with execution time is #{pg_time / 1_000} ms")

IO.inspect("Retriving orders with warehoure status")

params = %{
  page: 1000,
  size: 100,
  shipment_warehouse_status: "wh_packed"
}

{:ok, es_query} = BuildOrderEsQuery.perform(params)

{es_time, {:ok, es_count}} =
  :timer.tc(fn -> Repository.count_es_orders(es_query, orders_index) end)

IO.inspect("ES: retrive #{es_count} orders with execution time is #{es_time / 1_000} ms")

{:ok, pg_query} = BuildOrderQuery.perform(params)

{pg_time, pg_count} =
  :timer.tc(fn -> Repository.count_orders(pg_query) end)

IO.inspect("PG: retrive #{pg_count} orders with execution time is #{pg_time / 1_000} ms")
