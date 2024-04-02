defmodule Web.Controllers.Session do
  use Web, :controller

  def show(%{path_params: %{"id" => session_id}} = conn, _) do
    case Core.Session.Service.get(session_id) do
      {:ok, state} ->
        conn
        |> put_status(:ok)
        |> json(%{session: state})

      {:error, _} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not found."})
    end
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
        |> json(%{error: "Failed to create session."})
    end
  end
end
