defmodule TheBestory.GraphQL.Type.User do
  @moduledoc false

  use Absinthe.Ecto, repo: TheBestory.Repo
  use Absinthe.Schema.Notation

  alias TheBestory.GraphQL.Resolver

  @desc """
  A user is an individual's account on The Bestory.
  """
  object :user do
    @desc "Snowflake ID of the user."
    field :id, :snowflake

    @desc "Unique user's handle."
    field :username, :string

    @desc "User's nickname."
    field :nickname, :string

    @desc "Number of user's posts. This includes the actual posts and replies."
    field :posts_count, :integer

    @desc "Number of liked posts by the user."
    field :likes_count, :integer

    @desc "A flag indicating the profile is closed from viewing by others."
    field :is_protected, :boolean

    @desc "A flag indicating the account is suspended."
    field :is_suspended, :boolean

    @desc "Date and time when user account was created."
    field :registered_at, :datetime

    @desc "List of user's posts. This includes the actual posts and replies."
    field :posts, list_of(:post) do
      @desc "Listing type of the posts."
      arg :type, :post_listing_type, default_value: :latest

      @desc "Snowflake IDs of topics of posts."
      arg :topics, list_of(non_null(:snowflake))

      @desc "Post's Snowflake ID, before which to list the posts."
      arg :before, :snowflake

      @desc "Post's Snowflake ID, after which to list the posts."
      arg :after, :snowflake

      @desc "Number of posts in the list."
      arg :limit, :integer, default_value: 100

      resolve assoc(:posts, fn query, args, info ->
        Resolver.Post.list(query, args, info)
      end)
    end
  
    @desc "List of liked posts by the user."
    field :likes, list_of(:like), resolve: assoc(:likes)
  end
end
