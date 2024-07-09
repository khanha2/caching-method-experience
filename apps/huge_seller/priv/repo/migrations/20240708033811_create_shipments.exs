defmodule HugeSeller.Repo.Migrations.CreateShipments do
  use Ecto.Migration

  def change do
    create table(:shipments) do
      add(:code, :text)
      add(:order_code, :text)
      add(:store_code, :text)
      add(:warehouse_platform_code, :text)
      add(:warehouse_shipment_code, :text)
      add(:warehouse_code, :text)
      add(:delivery_platform_code, :text)
      add(:tracking_code, :text)
      add(:package_code, :text)
      add(:type, :text)
      add(:status, :text)
      add(:warehouse_status, :text)
      add(:delivery_status, :text)
      add(:created_at, :naive_datetime)

      add(:order_id, references(:orders, on_delete: :nilify_all))

      timestamps(default: fragment("NOW()"))
    end

    create(unique_index(:shipments, [:code]))
    create(index(:shipments, [:type]))
    create(index(:shipments, [:warehouse_platform_code]))
    create(index(:shipments, [:warehouse_code]))
    create(index(:shipments, [:status]))
    create(index(:shipments, [:warehouse_status]))
    create(index(:shipments, [:delivery_platform_code]))
    create(index(:shipments, [:delivery_status]))
    create(index(:shipments, [:created_at]))
    create(index(:shipments, [:updated_at]))
  end
end
