defmodule Core.Session.Server do
  use GenServer
  alias Phoenix.PubSub

  @pub_sub Core.PubSub

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

  def init([room_id, admin_user]) do
    task_id = UUID.uuid4()
    admin_id = UUID.uuid4()

    state =
      @initial_state
      |> Map.put(:id, room_id)
      |> Map.put(:admin, admin_id)
      |> Map.update!(:users, &Map.put(&1, admin_id, admin_user))
      |> Map.update!(:current_task, &Map.put(&1, :id, task_id))

    # GenServer.cast(self(), :clean_up)

    {:ok, state}
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def handle_call({:update_task, draft}, _from, state) do
    task_properties =
      draft |> cast_task()

    next_state =
      state
      |> Map.update!(:current_task, &Map.merge(&1, task_properties))

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

    {:reply, next_state, next_state}
  end

  def handle_call({:vote, user_id, value}, _from, state) do
    next_state =
      state
      |> update_in([:current_task, :votes, user_id], fn _ -> value end)

    PubSub.broadcast(@pub_sub, state.id, {:vote, %{user_id => value}})

    {:reply, next_state, next_state}
  end

  # Swarm

  def handle_call({:swarm, :begin_handoff}, _from, state) do
    {:reply, {:resume, state}, state}
  end

  def handle_cast({:swarm, :end_handoff, _}, state) do
    {:noreply, state}
  end

  def handle_info({:swarm, :die}, state) do
    {:stop, :shutdown, state}
  end

  # Helpers

  defp cast_task(draft) do
    draft
    |> Map.filter(fn {key, _} -> key in ["title"] end)
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end
end
