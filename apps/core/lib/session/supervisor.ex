defmodule Core.Session.Supervisor do
  use DynamicSupervisor

  @session Core.Session.Server
  @registry Core.Session.Registry

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def start_child(admin_user) do
    session_id = UUID.uuid4()
    opts = [session_id, admin_user]

    with {:ok, pid} <- DynamicSupervisor.start_child(__MODULE__, {@session, opts}),
         {:ok, _} <- Registry.register(@registry, session_id, pid) do
      pid
    else
      _ -> {:error, :failed_to_start_child}
    end
  end
end
