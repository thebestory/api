defmodule TheBestory.Repo.Schema.Snowflake do
  @moduledoc false

  use TheBestory.Repo.Schema

  alias TheBestory.Repo.Schema.{Snowflake}

  schema "snowflakes" do
    field :type, :string
  end

  def changeset(struct, attrs \\ %{})
  def changeset(%Snowflake{} = snowflake, attrs),
    do: snowflake |> change |> changeset(attrs)
  def changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:id, :type])
    |> validate_required([:id, :type])
    |> validate_length(:type, min: 1, max: 32)
  end
end
