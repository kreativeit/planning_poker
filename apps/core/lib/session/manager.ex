defmodule Core.Session.Manager do
  use GenServer

  @impl true
  def init(_init_arg) do
    {:ok, %{}}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  # Client

  # Server
  @impl true
  def handle_call({:lookup, :local, session_id}, _from, state) do
    case local_lookup(state, session_id) do
      {:ok, info} ->
        {:reply, info, state}

      _ ->
        {:reply, :not_found, state}
    end
  end

  def handle_call({:lookup, :cluster, session_id}, _from, state) do
    case local_lookup(state, session_id) do
      {:ok, info} ->
        {:reply, info, state}

      _ ->
        case cluster_lookup(session_id) do
          {:ok, info} ->
            {:reply, info, Map.put(state, session_id, info)}

          _ ->
            {:reply, :not_found, state}
        end
    end
  end

  @impl true
  def handle_cast({:unset, session_id}, state) do
    {:noreply, Map.delete(state, session_id)}
  end

  def unset(session_id) do
    GenServer.abcast(Core.Session.Manager, {:unset, session_id})
  end

  def lookup(session_id) do
    GenServer.call(__MODULE__, {:lookup, :cluster, session_id})
  end

  def cluster_lookup(session_id) do
    {replies, _} =
      GenServer.multi_call(Node.list(), __MODULE__, {:lookup, :local, session_id})

    cluster_result =
      replies
      |> Enum.map(&elem(&1, 1))
      |> Enum.find(&(&1 !== :not_found))

    case cluster_result do
      info when is_tuple(info) ->
        {:ok, info}

      _ ->
        # :logger.error("[Core.Session.Manager] Cluster lookup failed", session_id)
        {:error, :not_found}
    end
  end

  def local_lookup(state, session_id) do
    case Map.get(state, session_id) do
      info when not is_nil(info) ->
        {:ok, info}

      nil ->
        case Registry.lookup(Core.Registry, session_id) do
          [{pid, _}] when is_pid(pid) ->
            {:ok, {Node.self(), pid}}

          _ ->
            {:error, :not_found}
        end
    end
  end
end
