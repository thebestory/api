defmodule TheBestory.Repo.Schema.Topic do
  @moduledoc false

  use TheBestory.Repo.Schema

  alias TheBestory.Repo.Schema.{Post, PostTopic, Topic}

  schema "topics" do
    field :title,       :string
    field :slug,        :string
    field :description, :string, default: ""

    field :posts_count, :integer, default: 0

    field :is_public,   :boolean, default: false

    many_to_many :posts, Post, join_through: PostTopic
  end

  def changeset(struct, attrs \\ %{})
  def changeset(%Topic{} = topic, attrs),
    do: topic |> change |> changeset(attrs)
  def changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:title, :slug, :description, :is_public])
    |> validate_required([:title, :slug])
    |> validate_length(:title, min: 1, max: 64)
    |> validate_length(:slug, min: 1, max: 32)
    |> validate_length(:description, max: 2048)
    |> unique_constraint(:slug, name: :topics_slug_uindex)
  end
end
