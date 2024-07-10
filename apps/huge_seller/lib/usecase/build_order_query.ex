defmodule HugeSeller.Usecase.BuildOrderQuery do
  @moduledoc """
  Build query for order

  Process

  1. Build order condition
    1.1. Build order created time condition
    1.2. Build condition for other order fields
  2. Build shipment condition
    2.1. Build shipment created time condition
    2.2. Build condition for other shipment fields
  """
  import Ecto.Query

  alias HugeSeller.Parser

  @schema %{
    order_codes: [type: {:array, :string}, cast_func: &Parser.to_string_array/1],
    platform_code: :string,
    store_code: :string,
    group_brand_code: :string,
    status: :string,
    created_from: :utc_datetime,
    created_to: :utc_datetime,

    # Platform
    platform_order_code: :string,
    platform_status: :string,
    platform_skus: [type: {:array, :string}, cast_func: &Parser.to_string_array/1],

    # Shipment
    shipment_codes: [type: {:array, :string}, cast_func: &Parser.to_string_array/1],
    shipment_type: :string,
    shipment_created_from: :utc_datetime,
    shipment_created_to: :utc_datetime,
    shipment_warehouse_platform_code: :string,
    shipment_warehouse_code: :string,
    shipment_status: :string,
    shipment_warehouse_status: :string,
    shipment_delivery_platform_code: :string,
    shipment_delivery_status: :string,
    shipment_warehouse_skus: [type: {:array, :string}, cast_func: &Parser.to_string_array/1]
  }

  @order_fields [
    :order_codes,
    :platform_code,
    :store_code,
    :group_brand_code,
    :status,
    :platform_order_code,
    :platform_status,
    :platform_skus
  ]

  @shipment_fields [
    :shipment_codes,
    :shipment_type,
    :shipment_warehouse_platform_code,
    :shipment_warehouse_code,
    :shipment_status,
    :shipment_warehouse_status,
    :shipment_delivery_platform_code,
    :shipment_delivery_status,
    :shipment_warehouse_skus
  ]

  def perform(params) do
    with {:ok, data} <- Parser.cast(params, @schema) do
      query =
        from(HugeSeller.Schema.Order, as: :order)
        |> build_created_time_condition(data[:created_from], data[:created_to])

      query =
        data
        |> Map.take(@order_fields)
        |> Enum.reduce(query, fn
          {_key, nil}, acc ->
            acc

          {key, value}, acc ->
            build_order_condition(acc, key, value)
        end)

      has_shipment_query =
        data
        |> Map.take(@shipment_fields ++ [:shipment_created_from, :shipment_created_to])
        |> Map.keys()
        |> case do
          [] -> false
          _ -> true
        end

      shipment_query =
        from(HugeSeller.Schema.Shipment, as: :shipment)
        |> build_shipment_created_time_condition(
          data[:shipment_created_from],
          data[:shipment_created_to]
        )

      shipment_query =
        data
        |> Map.take(@shipment_fields)
        |> Enum.reduce(shipment_query, fn
          {_key, nil}, acc ->
            acc

          {key, value}, acc ->
            build_shipment_condition(acc, key, value)
        end)

      if has_shipment_query do
        {:ok, where(query, exists(where(shipment_query, order_id: parent_as(:order).id)))}
      else
        {:ok, query}
      end
    end
  end

  # 1. Build order condition

  # 1.1. Build order created time condition
  defp build_created_time_condition(query, created_from, created_to) do
    query =
      if created_from do
        where(query, [order], order.created_at >= ^created_from)
      else
        query
      end

    if created_to do
      where(query, [order], order.created_at <= ^created_to)
    else
      query
    end
  end

  # 1.2. Build condition for other order fields
  defp build_order_condition(query, :order_codes, codes) do
    where(query, [order], order.code in ^codes)
  end

  defp build_order_condition(query, :platform_skus, skus) do
    item_query =
      where(HugeSeller.Schema.OrderItem, [item], item.product_sku in ^skus)

    where(query, exists(where(item_query, order_id: parent_as(:order).id)))
  end

  defp build_order_condition(query, key, value) do
    where(query, [order], field(order, ^key) == ^value)
  end

  # 2. Build shipment condition

  # 2.1. Build shipment created time condition

  defp build_shipment_created_time_condition(query, created_from, created_to) do
    query =
      if created_from do
        where(query, [shipment], shipment.created_at >= ^created_from)
      else
        query
      end

    if created_to do
      where(query, [shipment], shipment.created_at <= ^created_to)
    else
      query
    end
  end

  # 2.2. Build condition for other shipment fields

  defp build_shipment_condition(query, :shipment_codes, value) do
    where(query, [shipment], shipment.code in ^value)
  end

  defp build_shipment_condition(query, :shipment_skus, value) do
    shipment_item_query =
      where(HugeSeller.Schema.ShipmentItem, [item], item.product_sku in ^value)

    where(query, exists(where(shipment_item_query, order_id: parent_as(:shipment).id)))
  end

  defp build_shipment_condition(query, key, value) do
    key =
      key
      |> to_string()
      |> String.replace("shipment_", "")
      |> String.to_atom()

    where(query, [shipment], field(shipment, ^key) == ^value)
  end
end
