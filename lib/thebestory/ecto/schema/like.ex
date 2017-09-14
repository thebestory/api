defmodule TheBestory.Ecto.Schema.Like do
  @moduledoc false

  use TheBestory.Ecto.Schema

  alias TheBestory.Ecto.Schema.{Like, Post, User}

  @primary_key false

  schema "likes" do
    belongs_to :user, User, primary_key: true
    belongs_to :post, Post, primary_key: true

    field :is_deleted,   :boolean, default: false

    field :submitted_at, Timex.Ecto.DateTime
    field :deleted_at, Timex.Ecto.DateTime
  end

  def changeset(struct, attrs \\ %{})
  def changeset(%Like{} = like, attrs),
    do: like |> change |> changeset(attrs)
  def changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:user_id, :post_id, :is_deleted])
    |> validate_required([:user_id, :post_id])
    |> put_submitted_at_datetime
    |> maybe_put_deleted_at_datetime
  end

  defp put_submitted_at_datetime(%Ecto.Changeset{} = changeset) do
    case get_state(changeset) do
      :built -> put_change(changeset, :submitted_at, Timex.now)
      _      -> changeset
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
