defmodule HugeSeller.Usecase.UpdateOrderShipment do
  import Ecto.Query

  require Logger

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
    with {:ok, data} <- HugeSeller.Parser.cast(params, @schema),
         :ok <- update_shipment(data),
         :ok <- HugeSeller.Usecase.Usecase.UpdateOrderShipmentCache.perform(params) do
      :ok
    end
  end

  defp update_shipment(params) do
    params
    |> Map.drop([:order_code, :shipment_code])
    |> Enum.filter(fn {_key, value} -> not is_nil(value) end)
    |> case do
      [] ->
        {:error, "no value to be updated"}

      values ->
        values
        |> Enum.into([], fn {key, value} ->
          key =
            key
            |> to_string()
            |> String.replace("shipment_", "")
            |> String.to_atom()

          {key, value}
        end)
        |> update_shipment(params.shipment_code)
        |> case do
          {1, _nil} ->
            :ok

          _error ->
            {:error, "failed to update shipment"}
        end
    end
  end

  defp update_shipment(values, shipment_code) do
    {time, result} =
      :timer.tc(fn ->
        HugeSeller.Schema.Shipment
        |> where(code: ^shipment_code)
        |> HugeSeller.Repo.update_all(set: values)
      end)

    Logger.warning("Updated shipment #{shipment_code} with execution time is #{time / 1_000} ms")

    result
  end
end
