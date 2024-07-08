defmodule HugeSeller.Repo.Migrations.CreateOrderItems do
  use Ecto.Migration

  def change do
    create table(:order_items) do
      add(:product_sku, :text)
      add(:warehouse_code, :text)
      add(:package_code, :text)
      add(:quantity, :integer)

      add(:order_id, references(:orders, on_delete: :delete_all))

      timestamps(default: fragment("NOW()"))
    end

    create(index(:order_items, [:product_sku]))
    create(index(:order_items, [:order_id]))
  end
end
