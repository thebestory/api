defmodule TheBestory.Endpoint do
  @moduledoc false

  use Plug.Router

  plug Plug.Static,
    at: "/", from: :thebestory, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  plug :match

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug TheBestory.Plug.Authorization

  plug :dispatch

  forward "/graphql", to: Absinthe.Plug,
    init_opts: [schema: TheBestory.GraphQL.Schema]

  forward "/graphiql", to: Absinthe.Plug.GraphiQL,
    init_opts: [schema: TheBestory.GraphQL.Schema]

  match _, do: send_resp(conn, 404, "")
end
