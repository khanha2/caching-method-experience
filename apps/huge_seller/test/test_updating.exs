alias HugeSeller.Repository

alias HugeSeller.Usecase.BuildOrderEsQuery
alias HugeSeller.Usecase.BuildOrderQuery

orders_index = HugeSeller.ElasticClusterIndex.orders()

# Test updating shipment
:ok =
  HugeSeller.Usecase.UpdateOrderShipment.perform(%{
    order_code: "O10000",
    shipment_code: "O10000-1",
    shipment_status: "packed",
    shipment_warehouse_shipment_code: "WH-O10000-1",
    shipment_warehouse_status: "wh_packed",
    shipment_tracking_code: "DL-O10000-1",
    shipment_delivery_status: "dl_new"
  })

params = %{
  shipment_codes: "O10000-1",
  shipment_status: "packed",
  shipment_warehouse_status: "wh_packed",
  shipment_delivery_status: "dl_new"
}

{:ok, es_query} = BuildOrderEsQuery.perform(params)

{es_time, {:ok, es_count}} =
  :timer.tc(fn -> Repository.count_es_orders(es_query, orders_index) end)

IO.inspect("ES: retrive #{es_count} orders with execution time is #{es_time / 1_000} ms")

{:ok, pg_query} = BuildOrderQuery.perform(params)

{pg_time, pg_count} =
  :timer.tc(fn -> Repository.count_orders(pg_query) end)

IO.inspect("PG: retrive #{pg_count} orders with execution time is #{pg_time / 1_000} ms")
