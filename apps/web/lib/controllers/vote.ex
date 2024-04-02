defmodule Web.Controllers.Vote do
  use Web, :controller

  def create(%{path_params: %{"session_id" => session_id}} = conn, _) do
    user_id = conn.assigns[:user]
    %{body_params: %{"value" => value}} = conn

    case Core.Session.Service.vote(session_id, user_id, value) do
      {:ok, state} ->
        conn
        |> put_status(:ok)
        |> json(%{session: state})

      {:error, err} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: err})
    end
  end
end
