defmodule Core.Session.Manager do
  use GenServer

  # Client

  def unset(session_id) do
    GenServer.abcast(Core.Session.Manager, {:unset, session_id})
  end

  def lookup(session_id) do
    GenServer.call(__MODULE__, {:lookup, :cluster, session_id})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  # Server

  @impl true
  def init(_init_arg) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:lookup, :local, session_id}, _from, state) do
    case local_lookup(state, session_id) do
      {:ok, pid} ->
        {:reply, {:ok, pid}, state}

      _ ->
        {:reply, {:error, :not_found}, state}
    end
  end

  def handle_call({:lookup, :cluster, session_id}, _from, state) do
    case local_lookup(state, session_id) do
      {:ok, pid} ->
        {:reply, {:ok, pid}, state}

      _ ->
        case cluster_lookup(session_id) do
          {:ok, pid} ->
            {:reply, {:ok, pid}, Map.put(state, session_id, pid)}

          _ ->
            {:reply, {:error, :not_found}, state}
        end
    end
  end

  @impl true
  def handle_cast({:unset, session_id}, state) do
    {:noreply, Map.delete(state, session_id)}
  end

  defp cluster_lookup(session_id) do
    {replies, _} =
      GenServer.multi_call(Node.list(), __MODULE__, {:lookup, :local, session_id})

    cluster_result =
      replies
      |> Enum.find(&(&1 |> elem(1) |> elem(0) === :ok))

    case cluster_result do
      {_, {:ok, pid}} ->
        {:ok, pid}

      _ ->
        {:error, :not_found}
    end
  end

  defp local_lookup(state, session_id) do
    case Map.fetch(state, session_id) do
      {:ok, pid} ->
        {:ok, pid}

      :error ->
        case Registry.lookup(Core.Registry, session_id) do
          [{pid, _}] when is_pid(pid) ->
            {:ok, pid}

          _ ->
            {:error, :not_found}
        end
    end
  end
end
