defmodule TheBestory.GraphQL.Type.Topic do
  @moduledoc false

  use Absinthe.Ecto, repo: TheBestory.Repo
  use Absinthe.Schema.Notation

  alias TheBestory.GraphQL.Resolver

  @desc """
  Topics allows to divide the posts on The Bestory according to their context.
  """
  object :topic do
    @desc "Snowflake ID of the topic."
    field :id, :snowflake

    @desc "Topic's name."
    field :title, :string

    @desc "Topic's unique slug."
    field :slug, :string

    @desc "Topic's description."
    field :description, :string

    @desc "Approximate number of posts in the topic."
    field :posts_count, :integer

    @desc "A flag indicating the topic is public."
    field :is_public, :boolean

    @desc "List of topic's posts."
    field :posts, list_of(:post) do
      @desc "Listing type of the posts."
      arg :type, :post_listing_type, default_value: :latest

      @desc "Snowflake IDs of authors of posts."
      arg :authors, list_of(non_null(:snowflake))

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
  end
end
