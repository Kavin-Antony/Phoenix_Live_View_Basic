defmodule LvBasics.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LvBasicsWeb.Telemetry,
      LvBasics.Repo,
      {DNSCluster, query: Application.get_env(:lv_basics, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LvBasics.PubSub},
      # Start a worker by calling: LvBasics.Worker.start_link(arg)
      # {LvBasics.Worker, arg},
      # Start to serve requests, typically the last entry
      LvBasicsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LvBasics.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LvBasicsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
