defmodule Core.Application do
  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      Core.Session.Manager,
      {Phoenix.PubSub, name: Core.PubSub},
      {Registry, keys: :unique, name: Core.Registry},
      {Core.Session.Supervisor, strategy: :one_for_one},
      {Cluster.Supervisor, [topologies, [name: Core.ClusterSupervisor]]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Core.Supervisor)
  end
end
