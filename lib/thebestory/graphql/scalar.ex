defmodule TheBestory.GraphQL.Scalar do
  @moduledoc false

  use Absinthe.Schema.Notation

  alias TheBestory.GraphQL.Scalar

  import_types Scalar.DateTime
  import_types Scalar.Snowflake
end
