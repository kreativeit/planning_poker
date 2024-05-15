defmodule Core.Session.Server do
  alias Core.Session.User
  alias Core.Session.State
  alias Core.Session.State.Task

  use GenServer, restart: :transient

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
  def init(admin_user) do
    admin = User.new!(name: admin_user)
    task = Task.new!(title: "New Task!")

    state =
      State.new!()
      |> State.set_admin_user(admin)
      |> State.put_task(task)

    Registry.register(Core.Registry, state.id, self())
    Process.send_after(self(), :heartbeat, heartbeat_interval())

    {:ok, state}
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  @impl true
  def handle_call({:update_task, draft}, _from, state) do
    task = Task.new!(draft)

    next_state =
      state
      |> State.merge_current_task(task)
      |> State.tick()

    {:reply, next_state, next_state}
  end

  def handle_call({:create_task, draft}, _from, state) do
    task = Task.new!(draft)

    next_state =
      state
      |> State.move_current_task_to_history()
      |> State.put_task(task)
      |> State.tick()

    {:reply, next_state, next_state}
  end

  def handle_call({:vote, user_id, vote}, _from, state) do
    next_state =
      state
      |> State.add_vote({user_id, vote})
      |> State.tick()

    {:reply, next_state, next_state}
  end

  def handle_call(:get, _from, state) do
    next_state =
      state
      |> State.tick()

    {:reply, next_state, next_state}
  end

  @impl true
  def handle_info(:heartbeat, state) do
    id = Map.fetch!(state, :id)

    unless State.expired?(state) do
      :logger.debug("[Session #{id}] Hearbeat @ #{DateTime.now!("Etc/UTC")}.")
      Process.send_after(self(), :heartbeat, heartbeat_interval())
      {:noreply, state}
    else
      :logger.info("[Session #{id}] Reached max time inactive duration. Exiting.")
      {:stop, :normal, state}
    end
  end

  @impl true
  def terminate(_reason, state) do
    session_id = Map.fetch!(state, :id)

    Core.Session.Manager.unset(session_id)
    :logger.info("[Session #{session_id}] Terminating.")
  end

  defp heartbeat_interval do
    Application.fetch_env!(:core, Core.Session.Server)
    |> Keyword.fetch!(:heartbeat_interval_milliseconds)
  end
end
