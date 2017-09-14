defmodule TheBestory.GraphQL.Resolver.Like do
  @moduledoc false

  use TheBestory.GraphQL.Resolver

  alias TheBestory.Ecto.Schema.Like

  @listing_min_limit 1
  @listing_max_limit 1000
  @listing_default_limit 100

end
