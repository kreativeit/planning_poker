defmodule Core.Session.Server do
  use GenServer

  @initial_state %{
    id: "",
    admin: "",
    users: %{},
    history: [],
    current_task: %{
      title: "",
      votes: %{}
    }
  }

  # Client

  def get(pid) do
    GenServer.call(pid, :get)
  end

  # Server

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init([room_id, admin_user]) do
    admin_id = UUID.uuid4()

    state =
      @initial_state
      |> Map.put(:id, room_id)
      |> Map.put(:admin, admin_id)
      |> Map.update!(:users, &Map.put(&1, admin_id, admin_user))

    {:ok, state}
  end

  def handle_call(_request, _from, state) do
    {:reply, state, state}
  end

  # def handle_call({:join, user}, _from, state) do
  #   new_state =
  #     state
  #     |> Map.put(:users, state.users |> Map.put(user, UUID.uuid4()))

  #   {:reply, new_state, new_state}
  # end

  # def handle_call({:create, user}, _from, state) do
  #   new_state = Map.put(state, :users, %{user => UUID.uuid4()})
  #   {:reply, new_state, new_state}
  # end
end
