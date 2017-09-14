defmodule TheBestory.GraphQL.Resolver do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      import Ecto.Query
      import Ecto.Changeset
      import Absinthe.Resolution.Helpers, only: [batch: 3]

      alias TheBestory.Repo
    end
  end
end
