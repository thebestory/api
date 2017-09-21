defmodule TheBestory.GraphQL.Type.Session do
  @moduledoc false

  use Absinthe.Ecto, repo: TheBestory.Repo
  use Absinthe.Schema.Notation

  @desc """
  Session is an authorized access to user's account and the ability to perform actions on behalf of this account.
  """
  object :session do
    @desc "Snowflake ID of the session."
    field :id, :snowflake

    @desc "User, this session belongs to."
    field :user, :user

    @desc "Session's JWT."
    field :token, :string
  end
end
