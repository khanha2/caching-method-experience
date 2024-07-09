defmodule HugeSeller.Usecase.CreateOrderCache do
  def perform(order) do
    params = %{
      id: order.code,
      code: order.code,
      status: order.status,
      platform_status: order.platform_status,
      created_at: order.created_at,
      store_code: order.store_code,
      shipments: Enum.map(order.shipments, &build_shipment_index(&1))
    }

    Elasticsearch.put(HugeSeller.ElasticCluster, "/#{index}/_doc/#{order_id}", params)
  end

  defp build_shipment_index(shipment) do
    %{
      code: shipment.code,
      type: shipment.type,
      created_at: shipment.created_at,
      warehouse_platform_code: shipment.warehouse_platform_code,
      warehouse_code: shipment.warehouse_code,
      status: shipment.status,
      warehouse_status: shipment.warehouse_status,
      delivery_platform_code: shipment.delivery_platform_code,
      delivery_status: shipment.delivery_status
    }
  end
end
