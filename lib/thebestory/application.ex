defmodule TheBestory.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(TheBestory.Repo, []),
      {Plug.Adapters.Cowboy, 
        scheme: :http, 
        plug: TheBestory.Endpoint,
        options: Application.get_env(:thebestory, TheBestory.Endpoint)}
    ]

    opts = [strategy: :one_for_one, name: TheBestory.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
