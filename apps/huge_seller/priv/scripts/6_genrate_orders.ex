defmodule GenerateOrders do
  alias Ecto.Multi

  alias HugeSeller.Schema.Order
  alias HugeSeller.Schema.Shipment
  alias HugeSeller.Schema.ShipmentStatus
  alias HugeSeller.Schema.ShipmentType

  @skus [
    "SKU-1",
    "SKU-2",
    "SKU-3",
    "SKU-3.1",
    "SKU-3.2",
    "SKU-4",
    "SKU-5",
    "SKU-6",
    "SKU-7",
    "SKU-7.1",
    "SKU-7.2",
    "SKU-8",
    "SKU-9",
    "SKU-10"
  ]

  @bundle_skus [
    "SKU-3",
    "SKU-5",
    "SKU-7"
  ]

  @bundle_sku_map %{
    "SKU-3" => ["SKU-3.1", "SKU-3.2"],
    "SKU-5" => ["SKU-5.1", "SKU-5.2"],
    "SKU-7" => ["SKU-7.1", "SKU-7.2", "SKU-7.3"]
  }

  @warehouse_codes ["WH1", "WH2", "WH3"]

  @warehouse_platform_map %{
    "WH1" => "WP1",
    "WH2" => "WP2",
    "WH3" => "WP1"
  }

  @delivery_platform_codes ["DL1", "DL2"]

  def perform(total, orders_per_second \\ 1) do
    starting_time =
      HugeSeller.DateTimeHelper.utc_now()
      |> Map.merge(%{hour: 0, minute: 0, second: 0})

    Enum.each(1..total, fn number ->
      create_order(number, starting_time, orders_per_second)
    end)
  end

  defp create_order(number, starting_time, orders_per_second) do
    Multi.new()
    |> insert_order(number, starting_time, orders_per_second)
    |> insert_order_items(number)
    |> insert_shipments()
    |> HugeSeller.Repo.transaction()
    |> case do
      {:ok, changes} ->
        order = changes[:order]
        {_count, items} = changes[:order_items]
        shipments = changes[:shipments]

        order = Map.merge(order, %{items: items, shipments: shipments})

        Elasticsearch.put_document(HugeSeller.ElasticCluster, order, "orders")

        HugeSeller.Usecase.CreateOrderCache.perform(order)

      _error ->
        nil
    end
  end

  defp insert_order(multi, number, starting_time, orders_per_second) do
    seconds = orders_per_second * div(number, orders_per_second)

    params = %{
      code: "O#{number}",
      store_code: "S1",
      created_at: DateTime.add(starting_time, seconds),
      platform_status: "pl_new"
    }

    Multi.insert(multi, :order, Order.changeset(%Order{}, params))
  end

  defp insert_order_items(multi, total_items) do
    items =
      Enum.map(1..total_items, fn _ ->
        sku = Enum.random(@skus)
        quantity = Enum.random(1..5)
        package_number = Enum.random(1..2)

        warehouse_code = Enum.random(@warehouse_codes)

        %{
          product_sku: sku,
          warehouse_code: warehouse_code,
          package_code: "P#{package_number}",
          quantity: quantity
        }
      end)

    Multi.insert_all(
      multi,
      :order_items,
      HugeSeller.Schema.OrderItem,
      fn %{order: order} ->
        Enum.map(items, &Map.put(&1, :order_id, order.id))
      end,
      returning: true
    )
  end

  defp insert_shipments(multi) do
    Multi.run(multi, :shipments, fn repo, %{order: order, order_items: {_count, items}} ->
      shipments = insert_shipments_with_repo(order, items, repo)
      {:ok, shipments}
    end)
  end

  defp insert_shipments_with_repo(order, order_items, repo) do
    order_items
    |> Enum.group_by(&{&1.warehouse_code, &1.package_code})
    |> Enum.with_index(1)
    |> Enum.map(fn {{{warehouse_code, package_code}, items}, index} ->
      prepare_package_shipments(warehouse_code, package_code, order, index, items)
    end)
    |> Enum.concat()
    |> Enum.map(fn {raw_shipment, raw_items} ->
      {:ok, shipment} =
        %Shipment{}
        |> Shipment.changeset(raw_shipment)
        |> repo.insert()

      raw_items = Enum.map(raw_items, &Map.put(&1, :shipment_id, shipment.id))

      {_count, items} =
        repo.insert_all(HugeSeller.Schema.ShipmentItem, raw_items, returning: true)

      Map.put(shipment, :items, items)
    end)
  end

  defp prepare_package_shipments(warehouse_code, package_code, order, index, order_items) do
    {main_shipment, main_shipment_items} =
      prepare_main_shipment(warehouse_code, package_code, order, index, order_items)

    has_refulfilled_shipment = Enum.random([true, false])
    total_refulfillments = Enum.random(1..3)

    main_shipment =
      if has_refulfilled_shipment do
        Map.put(main_shipment, :status, ShipmentStatus.cancelled())
      else
        main_shipment
      end

    refulfilled_shipments =
      if has_refulfilled_shipment do
        prepare_refulfill_shipments(main_shipment, total_refulfillments)
      else
        []
      end

    [{main_shipment, main_shipment_items} | refulfilled_shipments]
  end

  defp prepare_main_shipment(warehouse_code, package_code, order, index, order_items) do
    shipment_code = "#{order.code}-#{index}"

    delivery_platform_code = Enum.random(@delivery_platform_codes)

    warehouse_status =
      case Enum.random([true, false]) do
        true ->
          "wh_#{ShipmentStatus.new()}"

        false ->
          nil
      end

    delivery_status =
      case Enum.random([true, false]) do
        true ->
          "dl_#{ShipmentStatus.new()}"

        false ->
          nil
      end

    shipment = %{
      code: shipment_code,
      order_code: order.code,
      store_code: order.store_code,
      warehouse_platform_code: @warehouse_platform_map[warehouse_code],
      warehouse_code: warehouse_code,
      warehouse_shipment_code: "#{warehouse_code}-#{shipment_code}",
      warehouse_status: warehouse_status,
      package_code: package_code,
      delivery_platform_code: delivery_platform_code,
      delivery_status: delivery_status,
      tracking_code: "T#{shipment_code}",
      order_id: order.id,
      type: ShipmentType.main(),
      status: ShipmentStatus.new(),
      created_at: DateTime.utc_now()
    }

    base_item = %{
      order_code: order.code,
      store_code: order.store_code,
      shipment_code: shipment_code
    }

    items =
      order_items
      |> Enum.map(fn item ->
        item_sku = item.product_sku
        quantity = item.quantity
        bundle_skus = @bundle_sku_map[item_sku]

        if bundle_skus do
          Enum.map(bundle_skus, fn sku ->
            Map.merge(base_item, %{product_sku: sku, quantity: quantity})
          end)
        else
          [Map.merge(base_item, %{product_sku: item_sku, quantity: quantity})]
        end
      end)
      |> Enum.concat()

    {shipment, items}
  end

  defp prepare_refulfill_shipments(main_shipment, total_refulfillments) do
    Enum.map(1..total_refulfillments, fn number ->
      status =
        if number == total_refulfillments do
          ShipmentStatus.new()
        else
          ShipmentStatus.cancelled()
        end

      code = "#{main_shipment.code}-RF-#{number}"

      shipment =
        Map.merge(main_shipment, %{code: code, type: ShipmentType.refulfilling(), status: status})

      sku = Enum.random(@skus -- @bundle_skus)

      items =
        [
          %{
            order_code: main_shipment.order_code,
            store_code: main_shipment.store_code,
            shipment_code: code,
            tracking_code: "T#{code}",
            product_sku: sku,
            quantity: 1
          }
        ]

      {shipment, items}
    end)
  end
end

GenerateOrders.perform(1)
