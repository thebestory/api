defmodule TheBestory.GraphQL.Scalar.Snowflake do
  @moduledoc false

  use Absinthe.Schema.Notation

  @desc """
  The `Snowflake` scalar type represents a unique object's ID called
  Snowflake ID. Snowflake ID is a 64 bit integer. Note that the 
  Snowflake ID values are returned as strings.
  """
  scalar :snowflake do
    parse &parse_snowflake/1
    serialize &Integer.to_string/1
  end

  defp parse_snowflake(%Absinthe.Blueprint.Input.String{value: value}) do
    case Integer.parse(value) do
      {int, _} -> {:ok, int}
      _        -> :error
    end
  end

  defp parse_snowflake(_) do
    :error
  end
end
