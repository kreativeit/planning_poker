defmodule Core.Session.Service do
  def create(user) do
    with pid <- Core.Session.Supervisor.start_child(user),
         state <- Core.Session.Server.get(pid) do
      {:ok, state}
    end
  end

  def get(session_id) do
    IO.inspect(Registry.lookup(Core.Session.Registry, session_id))
    {:ok, %{}}
  end
end
