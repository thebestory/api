defmodule TheBestory.Repo.Schema do
  @moduledoc false

  alias TheBestory.Repo.Type.Snowflake

  def get_state(%Ecto.Changeset{data: %{__meta__: %{state: state}}}),
    do: state

  def force_generate_snowflake_id(%Ecto.Changeset{} = changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{id: _}} ->
        # Skip, if Snowflake ID is set manually.
        changeset
      %Ecto.Changeset{data: %{id: _}} ->
        # If model has the Snowflake ID field, force generate it, but only if
        # it's a new.
        case get_state(changeset) do
          :built ->
            Ecto.Changeset.put_change(changeset, :id, Snowflake.autogenerate())
          _      ->
            changeset
        end
      _ ->
        changeset
    end
  end

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset
      import TheBestory.Repo.Schema, only: [get_state: 1,
                                            force_generate_snowflake_id: 1]

      @primary_key {:id, TheBestory.Repo.Type.Snowflake, autogenerate: true}
      @foreign_key_type TheBestory.Repo.Type.Snowflake
    end
  end
end
