defmodule TheBestory.GraphQL.Type do
  @moduledoc false

  use Absinthe.Schema.Notation

  alias TheBestory.GraphQL.Type

  import_types Type.Like
  import_types Type.Post
  import_types Type.Session
  import_types Type.Topic
  import_types Type.User
end
