defmodule Core.Session.Server do
  use GenServer, restart: :transient

  @max_session_duration_seconds 60 * 15
  @heartbeat_interval_miliseconds 15_000

  @initial_state %{
    id: "UUID",
    admin: "",
    users: %{},
    history: [],
    current_task: %{
      id: "UUID",
      title: "",
      votes: %{}
    }
  }

  # Client

  def get(pid) do
    GenServer.call(pid, :get)
  end

  def update_task(pid, task) do
    GenServer.call(pid, {:update_task, task})
  end

  def create_task(pid, task) do
    GenServer.call(pid, {:create_task, task})
  end

  def vote(pid, user_id, info) do
    GenServer.call(pid, {:vote, user_id, info})
  end

  # Server

  @impl true
  def init([room_id, admin_user]) do
    task_id = UUID.uuid4()
    admin_id = UUID.uuid4()

    state =
      @initial_state
      |> Map.put(:id, room_id)
      |> Map.put(:admin, admin_id)
      |> Map.update!(:users, &Map.put(&1, admin_id, admin_user))
      |> Map.update!(:current_task, &Map.put(&1, :id, task_id))
      |> update_at()

    Registry.register(Core.Registry, room_id, self())
    Process.send_after(self(), :heartbeat, @heartbeat_interval_miliseconds)

    {:ok, state}
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  @impl true
  def handle_call({:update_task, draft}, _from, state) do
    task_properties =
      draft |> cast_task()

    next_state =
      state
      |> Map.update!(:current_task, &Map.merge(&1, task_properties))
      |> update_at()

    {:reply, next_state, next_state}
  end

  def handle_call({:create_task, draft}, _from, state) do
    curr_task =
      state
      |> Map.get(:current_task)

    task_properties =
      @initial_state
      |> Map.get(:current_task)
      |> Map.merge(draft |> cast_task() |> Map.put(:id, UUID.uuid4()))

    next_state =
      state
      |> Map.put(:current_task, task_properties)
      |> Map.update!(:history, fn history -> [curr_task | history] end)
      |> update_at()

    {:reply, next_state, next_state}
  end

  def handle_call({:vote, user_id, value}, _from, state) do
    next_state =
      state
      |> update_in([:current_task, :votes, user_id], fn _ -> value end)
      |> update_at()

    {:reply, next_state, next_state}
  end

  def handle_call(:get, _from, state) do
    next_state = state |> update_at()
    {:reply, next_state, next_state}
  end

  @impl true
  def handle_info(:heartbeat, state) do
    id = Map.fetch!(state, :id)

    expiration_date =
      Map.fetch!(state, :updated_at)
      |> DateTime.add(@max_session_duration_seconds)

    unless DateTime.after?(DateTime.now!("Etc/UTC"), expiration_date) do
      Process.send_after(self(), :heartbeat, @heartbeat_interval_miliseconds)
      {:noreply, state}
    else
      :logger.info("session #{id} reached max time inactive duration. exiting.")
      {:stop, :normal, state}
    end
  end

  # Helpers

  defp cast_task(draft) do
    draft
    |> Map.filter(fn {key, _} -> key in ["title"] end)
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp update_at(state, value \\ DateTime.now!("Etc/UTC")) do
    state |> Map.put(:updated_at, value)
  end
end
