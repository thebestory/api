defmodule TheBestory.Plug.Authorization do
  @moduledoc false

  @behaviour Plug

  import Plug.Conn

  alias TheBestory.Repo
  alias TheBestory.Repo.Schema.User
  alias TheBestory.Util.JWT

  def init(opts), do: opts

  def call(conn, _) do
    case authorize(conn) do
      {:ok, nil, _} ->
        put_private(conn, :absinthe, %{context: %{
          authorization: nil
        }})
      {:ok, token, user} ->
        put_private(conn, :absinthe, %{context: %{
          authorization: %{
            token: token,
            user: user
          }
        }})
      {:error, message} ->
        conn
        |> send_resp(400, message)
        |> halt()
    end
  end

  defp authorize(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        case JWT.decode(token) do
          {:ok, %{"type" => "session", "user" => id} = _payload} ->
            case Repo.get(User, id) do
              nil  -> {:error, "Invalid authorization token."}
              user -> {:ok, token, user}
            end
          _ ->
            {:error, "Invalid authorization token."}
        end
      [] ->
        {:ok, nil, nil}
      _ ->
        {:error, "Invalid authorization header."}
    end
  end
end
