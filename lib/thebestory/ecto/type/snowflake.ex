defmodule TheBestory.Ecto.Type.Snowflake do
  @moduledoc false

  @behaviour Ecto.Type

  # Snowflake IDs are integers.
  def type, do: :integer

  # Cast Snowflake ID from the string representation.
  def cast(str) when is_binary(str) do
    case Integer.parse(str) do
      {int, _} -> cast(int)
      :error   -> :error
    end
  end

  # Snowflake ID can be only positive integer.
  def cast(int) when is_integer(int) and int >= 0, do: {:ok, int}

  # Everything else is a failure though.
  def cast(_), do: :error

  # When loading data from the database, we are guaranteed to
  # receive an integer (as databases are strict) and we will
  # just return it to be stored in the schema struct.
  def load(int) when is_integer(int) and int >= 0, do: {:ok, int}

  # When dumping data to the database, we *expect* an integer
  # but any value could be inserted into the struct, so we need
  # guard against them.
  def dump(int) when is_integer(int) and int >= 0, do: {:ok, int}
  def dump(_), do: :error

  # Autogenerate Snowflake IDs, if field is not set.
  def autogenerate do
    {:ok, id} = generate()
    id
  end

  def generate, do: Snowflake.next_id()
end
