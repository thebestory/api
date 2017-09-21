defmodule TheBestory.GraphQL.Type.Like do
  @moduledoc false

  use Absinthe.Ecto, repo: TheBestory.Repo
  use Absinthe.Schema.Notation

  @desc """
  Like allows to raise content on The Bestory in the rating.
  """
  object :like do
    @desc "User, who liked post."
    field :user, :user, resolve: assoc(:user)

    @desc "The post that liked."
    field :post, :post, resolve: assoc(:post)

    @desc "Date and time when post was liked."
    field :liked_at, :datetime

    @desc "A flag indicating the like is deleted."
    field :is_unliked, :boolean

    @desc "Date and time when like was deleted (or null otherwise)."
    field :unliked_at, :datetime
  end
end
