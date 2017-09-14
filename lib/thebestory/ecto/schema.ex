defmodule TheBestory.Ecto.Schema do
  @moduledoc false

  alias TheBestory.Ecto.Type.Snowflake

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset

      @primary_key      {:id, Snowflake, autogenerate: true}
      @foreign_key_type Snowflake

      defp force_generate_snowflake_id(%Ecto.Changeset{} = changeset) do
        case changeset do
          %Ecto.Changeset{changes: %{id: _}} ->
            # Skip, if Snowflake ID is set manually
            changeset
          %Ecto.Changeset{data: %{id: _}} ->
            # If model has the Snowflake ID field, force generate it,
            # but only if it's a new
            case get_state(changeset) do
              :built -> put_change(changeset, :id, Snowflake.generate())
              _      -> changeset
            end
          _ ->
            changeset
        end
      end

      defp get_state(%Ecto.Changeset{data: %{__meta__: %{state: state}}}), do: state
    end
  end
end
