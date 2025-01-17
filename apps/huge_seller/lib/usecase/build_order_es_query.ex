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
      conditions =
        case build_created_time_condition(data[:created_from], data[:created_to]) do
          nil -> []
          condition -> [condition]
        end

      conditions =
        data
        |> Map.take(@order_fields)
        |> Enum.reduce(conditions, fn
          {_key, nil}, acc ->
            acc

          {key, value}, acc ->
            [build_order_condition(key, value) | acc]
        end)

      conditions =
        case build_shipment_created_time_condition(
               data[:shipment_created_from],
               data[:shipment_created_to]
             ) do
          nil -> conditions
          condition -> [condition | conditions]
        end

      conditions =
        data
        |> Map.take(@shipment_fields)
        |> Enum.reduce(conditions, fn
          {_key, nil}, acc ->
            acc

          {key, value}, acc ->
            condition = %{
              "nested" => %{
                "path" => "shipments",
                "query" => build_shipment_condition(key, value)
              }
            }

            [condition | acc]
        end)

      {:ok, %{"query" => %{"bool" => %{"filter" => conditions}}}}
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
      nil
    else
      %{"range" => %{"created_at" => Enum.into(conditions, %{})}}
    end
  end

  # 1.2. Build condition for other order fields
  defp build_order_condition(:order_codes, codes) do
    conditions = Enum.map(codes, &%{"match_phrase" => %{"code" => &1}})
    %{"bool" => %{"should" => conditions, "minimum_should_match" => 1}}
  end

  defp build_order_condition(:platform_skus, skus) do
    conditions = Enum.map(skus, &%{"match_phrase" => %{"platform_skus" => &1}})
    %{"bool" => %{"should" => conditions, "minimum_should_match" => 1}}
  end

  defp build_order_condition(key, value) do
    %{"match_phrase" => %{to_string(key) => value}}
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
      nil
    else
      %{"range" => %{"shipments.created_at" => Enum.into(conditions, %{})}}
    end
  end

  # 2.2. Build condition for other shipment fields

  defp build_shipment_condition(:shipment_codes, codes) do
    conditions = Enum.map(codes, &%{"match_phrase" => %{"shipments.code" => &1}})
    %{"bool" => %{"should" => conditions, "minimum_should_match" => 1}}
  end

  defp build_shipment_condition(:shipment_warehouse_skus, skus) do
    conditions = Enum.map(skus, &%{"match_phrase" => %{"shipments.warehouse_skus" => &1}})
    %{"bool" => %{"should" => conditions, "minimum_should_match" => 1}}
  end

  defp build_shipment_condition(key, value) do
    key =
      key
      |> to_string()
      |> String.replace("shipment_", "shipments.")

    %{"match_phrase" => %{key => value}}
  end
end
