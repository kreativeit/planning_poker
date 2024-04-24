defmodule Core.Session.Supervisor do
  use DynamicSupervisor

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def register([session_id, admin]) do
    child_spec = {Core.Session.Server, [session_id, admin]}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def start_child(admin) do
    session_id = UUID.uuid4()
    child_spec = [session_id, admin]

    case Swarm.register_name(session_id, Core.Session.Supervisor, :register, [child_spec]) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, _} ->
        {:error, :failed_to_start_child}
    end
  end
end
