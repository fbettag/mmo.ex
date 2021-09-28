defmodule MMO.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MMOWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MMO.PubSub},
      # Start the Game Server
      MMO.Game.Server,
      # Start the Endpoint (http/https)
      MMOWeb.Endpoint
      # Start a worker by calling: MMO.Worker.start_link(arg)
      # {MMO.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MMO.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MMOWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
