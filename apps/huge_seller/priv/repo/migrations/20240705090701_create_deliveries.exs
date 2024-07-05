defmodule HugeSeller.Repo.Migrations.CreateDeliveries do
  use Ecto.Migration

  def change do
    create table(:deliveries) do
      add(:code, :text)
      add(:name, :text)
    end

    create(unique_index(:deliveries, [:code]))
  end
end
