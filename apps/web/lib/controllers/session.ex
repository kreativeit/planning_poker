defmodule Web.Controllers.Session do
  use Web, :controller

  def join(%{body_params: %{"user" => user, "session" => session_id}} = conn, _) do
    # case Core.Session.Service.create(user) do
    #   {:ok, state} ->
    #     conn
    #     |> put_status(:ok)
    #     |> json(%{session: state})

    #   {:error, _} ->
    #     conn
    #     |> put_status(:internal_server_error)
    #     |> json(%{error: "Failed to create session"})
    # end
  end

  def get(%{path_params: %{"id" => session_id}} = conn, _) do
    Core.Session.Service.get(session_id)

    conn
    |> put_status(:ok)
    |> json(%{session: %{}})
  end

  def create(%{body_params: %{"user" => user}} = conn, _) do
    case Core.Session.Service.create(user) do
      {:ok, state} ->
        conn
        |> put_status(:ok)
        |> json(%{session: state})

      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to create session"})
    end
  end

  def handle_vote() do
    {:ok, %{}}
  end

  def handle_leave() do
    {:ok, %{}}
  end
end
