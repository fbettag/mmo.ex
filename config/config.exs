# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :mmo,
  namespace: MMO

# Configures the endpoint
config :mmo, MMOWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: MMOWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MMO.PubSub,
  live_view: [signing_salt: "5hGNPAKP"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

if Mix.env() != :prod,
  do:
    config(
      :git_hooks,
      auto_install: true,
      verbose: true,
      hooks: [
        pre_commit: [
          tasks: [
            {:cmd, "mix clean"},
            {:cmd, "mix compile --warnings-as-errors"},
            {:cmd, "mix xref deprecated --abort-if-any"},
            {:cmd, "mix xref unreachable --abort-if-any"},
            {:cmd, "mix format --check-formatted"},
            {:cmd, "mix deps.audit"},
            {:cmd,
             "mix sobelow --exit --ignore Config.HTTPS,Config.Headers,Config.CSRFRoute,Config.CSP,Config.Secrets"},
            {:cmd, "mix credo --strict --ignore alias"},
            # {:cmd, "mix doctor --summary"},
            {:cmd, "mix test"}
          ]
        ]
      ]
    )

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
