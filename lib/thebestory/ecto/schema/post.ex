defmodule TheBestory.Ecto.Schema.Post do
  @moduledoc false

  use TheBestory.Ecto.Schema

  alias TheBestory.Ecto.Schema.{Like, Post, Topic, User}

  schema "posts" do
    belongs_to :author, User
    belongs_to :root,   Post
    belongs_to :parent, Post

    field :content,       :string

    field :replies_count, :integer, default: 0
    field :likes_count,   :integer, default: 0

    field :is_published,  :boolean, default: false
    field :is_deleted,    :boolean, default: false

    field :submitted_at,  Timex.Ecto.DateTime
    field :published_at,  Timex.Ecto.DateTime
    field :edited_at,     Timex.Ecto.DateTime
    field :deleted_at,    Timex.Ecto.DateTime

    many_to_many :topics,  Topic, join_through: "posts_topics"
    has_many     :replies, Post,  foreign_key: :parent_id
    has_many     :likes,   Like
  end

  def changeset(struct, attrs \\ %{})
  def changeset(%Post{} = post, attrs),
    do: post |> change |> changeset(attrs)
  def changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:author_id, :root_id, :parent_id, :content,
                    :is_published, :is_deleted, :published_at])
    |> validate_required([:author_id, :content])
    |> validate_length(:content, min: 1, max: 16384)
    |> force_generate_snowflake_id
    |> maybe_put_root_and_parent_ids
    |> put_submitted_at_datetime
    |> maybe_put_published_at_datetime
    |> maybe_put_edited_at_datetime
    |> maybe_put_deleted_at_datetime
  end

  defp maybe_put_root_and_parent_ids(%Ecto.Changeset{} = changeset) do
    changeset
    |> maybe_put_root_and_parent_ids(:root_id)
    |> maybe_put_root_and_parent_ids(:parent_id)
  end
  defp maybe_put_root_and_parent_ids(%Ecto.Changeset{} = changeset, field) do
    case get_field(changeset, field) do
      nil -> put_change(changeset, field, get_field(changeset, :id))
      _   -> changeset
    end
  end

  defp put_submitted_at_datetime(%Ecto.Changeset{} = changeset) do
    case get_state(changeset) do
      :built -> put_change(changeset, :submitted_at, Timex.now)
      _      -> changeset
    end
  end

  defp maybe_put_published_at_datetime(%Ecto.Changeset{} = changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{published_at: _}} ->
        # Skip, if published date is set manually
        changeset
      %Ecto.Changeset{changes: %{is_published: true}} ->
        # If `is_published` flag is set to true, set current date
        put_change(changeset, :published_at, Timex.now)
      _ ->
        case get_state(changeset) do
          :built ->
            # If post is not published, but a new, set current date
            # Because sorting is done by published date by default and
            # user can see their own unpublished (on moderation) posts,
            # thanks to this value, everything will be sorted in right
            # way
            put_change(changeset, :published_at, Timex.now)
          _ ->
            changeset
        end
    end
  end

  defp maybe_put_edited_at_datetime(%Ecto.Changeset{} = changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{content: _}} ->
        # We should set edited date only if it's not a new post
        case get_state(changeset) do
          :loaded -> put_change(changeset, :edited_at, Timex.now)
          _       -> changeset
        end
      _ ->
        changeset
    end
  end

  defp maybe_put_deleted_at_datetime(%Ecto.Changeset{} = changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{is_deleted: true}} ->
        put_change(changeset, :deleted_at, Timex.now)
      _ ->
        changeset
    end
  end
end
