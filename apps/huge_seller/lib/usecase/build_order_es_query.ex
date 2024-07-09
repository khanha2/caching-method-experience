defmodule HugeSeller.Usecase.BuildOrderEsQuery do
  @moduledoc """
  Build ES query for order

  Process

  1. Build order condition
    1.1. Build order created time condition
    1.2. Build condition for other order fields
  2. Build shipment condition
    2.1. Build shipment created time condition
    2.2. Build condition for other shipment fields
  """
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
    shipment_delivery_status: :string
  }

  @order_fields [
    :order_codes,
    :platform_code,
    :store_code,
    :group_brand_code,
    :status,
    :platform_order_code,
    :platform_status
  ]

  @shipment_fields [
    :shipment_codes,
    :shipment_type,
    :shipment_warehouse_platform_code,
    :shipment_warehouse_code,
    :shipment_status,
    :shipment_warehouse_status,
    :shipment_delivery_platform_code,
    :shipment_delivery_status
  ]

  def perform(params) do
    with {:ok, data} <- Parser.cast(params, @schema) do
      created_time_condition_map =
        build_created_time_condition(data[:created_from], data[:created_to])

      condition_map =
        params
        |> Map.take(@order_fields)
        |> Enum.reduce(created_time_condition_map, fn
          {_key, nil}, acc ->
            acc

          {key, value}, acc ->
            Map.merge(acc, build_order_condition(key, value))
        end)

      shipment_created_time_condition_map =
        build_created_time_condition(data[:shipment_created_from], data[:shipment_created_to])

      shipment_condition_map =
        params
        |> Map.take(@shipment_fields)
        |> Enum.reduce(shipment_created_time_condition_map, fn
          {_key, nil}, acc ->
            acc

          {key, value}, acc ->
            Map.merge(acc, build_shipment_condition(key, value))
        end)

      condition_map =
        if Map.keys(shipment_condition_map) == [] do
          condition_map
        else
          Map.put(
            condition_map,
            "nested",
            %{
              "path" => "shipments",
              "query" => %{"match_all" => shipment_condition_map}
            }
          )
        end

      {:ok, %{"query" => %{"match_all" => condition_map}}}
    end
  end

  # 1. Build order condition

  # 1.1. Build order created time condition
  defp build_created_time_condition(created_from, created_to) do
    conditions = []

    conditions =
      if created_from do
        [%{"gte" => created_from} | conditions]
      else
        conditions
      end

    conditions =
      if created_to do
        [%{"lte" => created_to} | conditions]
      else
        conditions
      end

    if conditions == [] do
      %{}
    else
      %{"range" => %{"created_at" => Enum.into(conditions, %{})}}
    end
  end

  # 1.2. Build condition for other order fields
  defp build_order_condition(:order_codes, value) do
    %{"terms" => %{"order_code" => value}}
  end

  defp build_order_condition(key, value) do
    %{"term" => %{to_string(key) => value}}
  end

  # 2. Build shipment condition

  # 2.1. Build shipment created time condition

  defp build_shipment_created_time_condition(created_from, created_to) do
    conditions = []

    conditions =
      if created_from do
        [%{"gte" => created_from} | conditions]
      else
        conditions
      end

    conditions =
      if created_to do
        [%{"lte" => created_to} | conditions]
      else
        conditions
      end

    if conditions == [] do
      %{}
    else
      %{"range" => %{"shipments.created_at" => Enum.into(conditions, %{})}}
    end
  end

  # 2.2. Build condition for other shipment fields

  defp build_shipment_condition(:shipment_codes, value) do
    %{"terms" => %{"shipments.code" => value}}
  end

  defp build_shipment_condition(key, value) do
    key =
      key
      |> to_string()
      |> String.replace("shipment_", "shipments.")

    %{"term" => %{key => value}}
  end
end
