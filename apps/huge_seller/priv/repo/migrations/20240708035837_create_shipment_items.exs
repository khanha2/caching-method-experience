defmodule HugeSeller.Repo.Migrations.CreateShipmentItems do
  use Ecto.Migration

  def change do
    create table(:shipment_items) do
      add(:order_code, :text)
      add(:store_code, :text)
      add(:shipment_code, :text)
      add(:product_sku, :text)
      add(:quantity, :integer)

      add(:shipment_id, references(:shipments, on_delete: :delete_all))

      timestamps(default: fragment("NOW()"))
    end

    create(index(:shipment_items, [:order_code]))
    create(index(:shipment_items, [:store_code]))
    create(index(:shipment_items, [:shipment_code]))
    create(index(:shipment_items, [:product_sku]))
  end
end
