defmodule TheBestory.Ecto.Type.SnowflakeTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Snowflake, as: SnowflakeServer
  alias TheBestory.Ecto.Type.Snowflake, as: SnowflakeType

  test "Snowflake.generate/0 works" do
    {:ok, id} = SnowflakeType.generate()
    assert is_integer(id)
  end

  test "Snowflake.autogenerate/0 works" do
    id = SnowflakeType.autogenerate()
    assert is_integer(id)
  end

  describe "Snowflake.cast/1" do
    test "works with an integer" do
      {:ok, id} = SnowflakeServer.next_id()
      assert SnowflakeType.cast(id) == {:ok, id}
    end

    test "doesn't take negative integer" do
      id = -42
      assert SnowflakeType.cast(id) == :error
    end

    test "works with a string" do
      {:ok, id} = SnowflakeServer.next_id()
      assert SnowflakeType.cast(Integer.to_string(id)) == {:ok, id}
    end
  end

  test "Snowflake.load/0 works" do
    {:ok, id} = SnowflakeServer.next_id()
    assert SnowflakeType.load(id) == {:ok, id}
  end

  describe "Snowflake.dump/1" do
    test "works with an integer" do
      {:ok, id} = SnowflakeServer.next_id()
      assert SnowflakeType.dump(id) == {:ok, id}
    end

    test "doesn't take negative integer" do
      id = -42
      assert SnowflakeType.dump(id) == :error
    end
  end
end
