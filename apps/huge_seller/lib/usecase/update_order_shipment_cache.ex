defmodule HugeSeller.Usecase.Usecase.UpdateOrderShipmentCache do
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
    with {:ok, %{order_code: order_code} = data} <- HugeSeller.Parser.cast(params, @schema),
         {script, query} <- build_update_query(data),
         {:ok, _result} <-
           Elasticsearch.post(
             HugeSeller.ElasticCluster,
             "/#{@orders_index}/_update/#{order_code}",
             query
           ) do
      :ok
    end
  end

  @key_fields [
    :order_code,
    :shipment_code
  ]

  defp build_update_query(data) do
    change_script =
      data
      |> Map.drop(@key_fields)
      |> Enum.reduce([], fn
        {_key, nil}, acc ->
          acc

        {key, _value}, acc ->
          script_key = String.replace(key, "_", ".")
          ["#{script_key} = #{value}" | acc]
      end)
      |> Enum.join(";\n")

    script =
      """
      ctx._source.shipments.forEach(shipment -> {
        if (shipment.code == params.shipment_code) {
          #{change_script}
        }
      });
      """

    %{"script" => script, "params" => data}
  end
end
