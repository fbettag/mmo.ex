import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.
if config_env() == :prod do
  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :mmo, MMOWeb.Endpoint,
    secret_key_base: secret_key_base,
    env: System.get_env("MIX_ENV"),
    # cache_static_manifest: "priv/static/cache_manifest.json",
    secret_key_base: System.get_env("SECRET_KEY_BASE"),
    url: [
      host: System.get_env("PORTAL_HOST") || "mmo.k8s.el8.nl",
      port: 443,
      scheme: "https"
    ],
    http: [
      port: String.to_integer(System.get_env("PORT") || "4000"),
      protocol_options: [
        max_header_name_length: 64,
        max_header_value_length: 8192,
        max_headers: 100
      ]
    ],
    pubsub_server: MMO.PubSub,
    # pubsub: [name: MMO.PubSub, adapter: Phoenix.PubSub.PG2],
    # instrumenters: [MMOWeb.Endpoint.PhoenixInstrumenter]
    live_view: [
      signing_salt: System.get_env("SIGNING_SALT")
    ],
    check_origin: false,
    server: true,
    root: ".",
    version: Application.spec(:mmo, :vsn)

  # Do not print debug messages in production
  config :logger, level: :info

  # Strip out personal data in production
  config :phoenix, :filter_parameters, [
    "password",
    "password_confirmation",
    "first_name",
    "last_name",
    "phone",
    "email"
  ]

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  #     config :mmo, MMOWeb.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.
end
