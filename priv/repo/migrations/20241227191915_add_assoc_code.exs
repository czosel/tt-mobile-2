defmodule TtMobile.Repo.Migrations.AddAssocCode do
  use Ecto.Migration

  def change do
    alter table(:association) do
      add :code, :string
    end
  end
end
