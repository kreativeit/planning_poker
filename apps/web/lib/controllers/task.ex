defmodule Web.Controllers.Task do
  use Web, :controller

  def create(%{path_params: %{"session_id" => session_id}} = conn, _) do
    %{body_params: task} = conn

    case Core.Session.Service.create_task(session_id, task) do
      {:ok, state} ->
        conn
        |> put_status(:ok)
        |> json(%{session: state})

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  def update(%{path_params: %{"session_id" => session_id}} = conn, _) do
    %{body_params: task} = conn

    case Core.Session.Service.update_task(session_id, task) do
      {:ok, state} ->
        conn
        |> put_status(:ok)
        |> json(%{session: state})

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end
end
