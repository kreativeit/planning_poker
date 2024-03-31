defmodule Core.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DNSCluster, query: Application.get_env(:core, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Core.PubSub},
      {Registry, keys: :unique, name: Core.Session.Registry},
      {Core.Session.Supervisor, strategy: :one_for_one}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Core.Supervisor)
  end
end
