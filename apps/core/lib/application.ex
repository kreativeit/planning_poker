defmodule Core.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: Core.PubSub},
      {Core.Session.Supervisor, strategy: :one_for_one},
      {Registry, keys: :unique, name: Core.Session.Registry},
      {DNSCluster, query: Application.get_env(:core, :dns_cluster_query) || :ignore}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Core.Supervisor)
  end
end
