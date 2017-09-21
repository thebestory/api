defmodule TheBestory.GraphQL.Resolver.Session do
  @moduledoc false

  use TheBestory.GraphQL.Resolver

  alias TheBestory.Repo.Schema.User
  alias TheBestory.Util.{JWT, Password}

  # Process create

  def create(%{username: username, password: password} = _args, _info) do
    case Repo.get_by(User, username: username) do
      nil  ->
        {:error, "Incorrect username or password."}
      user ->
        case Password.match(password, user.password) do
          true -> 
            token = JWT.encode(%{
              "type" => "session",
              "user" => user.id
            })

            {:ok, %{
              id: JWT.get_jti(token),
              user: user,
              token: token
            }}
          _ ->
            {:error, "Incorrect username or password."}
        end
    end
  end
end
