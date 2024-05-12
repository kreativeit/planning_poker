defmodule Core.Session.Service do
  def create(user) do
    with {:ok, pid} <- Core.Session.Supervisor.start_child(user),
         state <- Core.Session.Server.get(pid) do
      {:ok, state}
    else
      _ -> {:error, :failure}
    end
  end

  def get(session_id) do
    with {:ok, pid} <- lookup(session_id),
         state <- Core.Session.Server.get(pid) do
      {:ok, state}
    else
      err -> err
    end
  end

  def vote(session_id, user_id, vote) do
    with {:ok, pid} <- lookup(session_id),
         state <- Core.Session.Server.vote(pid, user_id, vote) do
      {:ok, state}
    else
      err -> err
    end
  end

  def update_task(session_id, task) do
    with {:ok, pid} <- lookup(session_id),
         state <- Core.Session.Server.update_task(pid, task) do
      {:ok, state}
    else
      err -> err
    end
  end

  def create_task(session_id, task) do
    with {:ok, pid} <- lookup(session_id),
         state <- Core.Session.Server.create_task(pid, task) do
      {:ok, state}
    else
      err -> err
    end
  end

  defp lookup(session_id) do
    case Core.Session.Manager.lookup(session_id) do
      {_, pid} when is_pid(pid) -> {:ok, pid}
      _ -> {:error, :not_registered}
    end
  end
end
