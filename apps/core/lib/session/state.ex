defmodule Core.Session.User do
  @derive Jason.Encoder

  defstruct id: "UUID", name: ""

  def new!(fields) do
    struct!(__MODULE__, Keyword.put(fields, :id, UUID.uuid4()))
  end
end

defmodule Core.Session.State.Task do
  @derive Jason.Encoder
  defstruct id: "UUID", title: "", votes: %{}

  def new!(fields) do
    struct!(__MODULE__, Keyword.put(fields, :id, UUID.uuid4()))
  end

  def update_title(task, title) do
    %{task | title: title}
  end

  def add_vote(task, {user_id, vote}) do
    task
    |> Map.update!(:votes, &Map.put(&1, user_id, vote))
  end
end

defmodule Core.Session.State do
  alias Core.Session.User
  alias Core.Session.State.Task

  @derive Jason.Encoder
  defstruct id: "UUID", admin: "", users: %{}, history: [], task: nil, updated_at: nil

  def new! do
    struct!(__MODULE__, id: UUID.uuid4(), updated_at: DateTime.now!("Etc/UTC"))
  end

  def add_user(state, %User{} = user) do
    IO.inspect(user)

    state
    |> Map.update!(:users, &Map.put(&1, user.id, user))
  end

  def set_admin_user(state, %User{} = user) do
    state
    |> add_user(user)
    |> Map.put(:admin, user.id)
  end

  def add_vote(state, {user_id, vote}) do
    task =
      Map.fetch!(state, :task)
      |> Task.add_vote({user_id, vote})

    state
    |> put_task(task)
  end

  def put_task(state, %Task{} = task) do
    %{state | task: task}
  end

  def merge_current_task(state, draft) do
    state
    |> Map.update!(:task, &Map.merge(&1, draft))
  end

  def move_current_task_to_history(state) do
    current_task = Map.fetch!(state, :task)

    unless is_nil(current_task) do
      state
      |> Map.put(:task, nil)
      |> Map.put(:histoty, [state.history | current_task])
    else
      state
    end
  end

  def expired?(state) do
    expiration_threshold =
      Application.fetch_env!(:core, Core.Session.Server)
      |> Keyword.fetch!(:max_session_duration_milliseconds)

    expiration =
      Map.fetch!(state, :updated_at)
      |> DateTime.add(expiration_threshold, :millisecond)

    DateTime.now!("Etc/UTC")
    |> DateTime.after?(expiration)
  end

  def tick(state) do
    %{state | updated_at: DateTime.now!("Etc/UTC")}
  end
end
