defmodule HugeSeller.Usecase.Usecase.UpdateOrderShipmentCache do
  require Logger

  @orders_index HugeSeller.ElasticClusterIndex.orders()

  @code_type [type: :string, length: [min: 1]]

  @schema %{
    order_code: [type: :string, required: true],
    shipment_code: [type: :string, required: true],
    shipment_status: @code_type,
    shipment_warehouse_shipment_code: @code_type,
    shipment_warehouse_status: @code_type,
    shipment_tracking_code: @code_type,
    shipment_delivery_status: @code_type
  }

  def perform(params) do
    with {:ok, %{order_code: order_code, shipment_code: shipment_code} = data} <-
           HugeSeller.Parser.cast(params, @schema),
         {:ok, query} <- build_update_query(data),
         {:ok, _result} <- cache_shipment(order_code, shipment_code, query) do
      :ok
    end
  end

  @key_fields [
    :order_code,
    :shipment_code
  ]

  defp build_update_query(data) do
    # change_script =
    data
    |> Map.drop(@key_fields)
    |> Enum.reduce([], fn
      {_key, nil}, acc ->
        acc

      {key, _value}, acc ->
        script_key =
          key
          |> to_string()
          |> String.replace("shipment_", "")

        ["ctx._source.shipments[i].#{script_key} = params.#{key}" | acc]
    end)
    |> case do
      [] ->
        {:error, "no value to be updated"}

      change_parts ->
        change_script = Enum.join(change_parts, ";")

        script =
          "for (int i = 0; i < ctx._source.shipments.size(); i++) {if (ctx._source.shipments[i].code == params.shipment_code) {#{change_script};}}"

        {:ok, %{"script" => %{"source" => script, "params" => data}}}
    end
  end

  defp cache_shipment(order_code, shipment_code, query) do
    {time, result} =
      :timer.tc(fn ->
        Elasticsearch.post(
          HugeSeller.ElasticCluster,
          "/#{@orders_index}/_update/#{order_code}",
          query
        )
      end)

    Logger.warning(
      "Updated cache for order #{order_code} shipment #{shipment_code} with execution time is #{time / 1_000} ms"
    )

    result
  end
end
