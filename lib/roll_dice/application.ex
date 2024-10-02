defmodule RollDice.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :opentelemetry_cowboy.setup()
    OpentelemetryPhoenix.setup(adapter: :cowboy2)
    OpentelemetryEcto.setup([:dice_game, :repo]) # if using ecto

    children = [
      RollDiceWeb.Telemetry,
      RollDice.Repo,
      {DNSCluster, query: Application.get_env(:roll_dice, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RollDice.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: RollDice.Finch},
      # Start a worker by calling: RollDice.Worker.start_link(arg)
      # {RollDice.Worker, arg},
      # Start to serve requests, typically the last entry
      RollDiceWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RollDice.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RollDiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
