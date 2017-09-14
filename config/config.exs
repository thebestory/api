# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.

use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :thebestory, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:thebestory, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# General application configuration
config :thebestory,
  namespace: TheBestory,
  ecto_repos: [TheBestory.Repo]

# Database connection configuration
# Default parameters are set according to the Docker environment
config :thebestory, TheBestory.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "postgres",
  hostname: "postgres",
  port: 5432

# Snowflake ID generator configuration
config :snowflake,
  machine_id: 0,  # values are 0 thru 1023 nodes
  epoch: 1483228800000  # don't change after you decide what your epoch is

# Endpoint configuration
config :thebestory, TheBestory.Endpoint,
  port: 4000

# Elixir's Logger configuration
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).

import_config "#{Mix.env}.exs"
