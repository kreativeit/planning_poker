defmodule Core.Application do
  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      {Phoenix.PubSub, name: Core.PubSub},
      {Core.Session.Supervisor, strategy: :one_for_one},
      {Cluster.Supervisor, [topologies, [name: Core.ClusterSupervisor]]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Core.Supervisor)
  end
end
