defmodule Web.Router do
  use Web, :router

  import Plug.BasicAuth
  import Phoenix.LiveDashboard.Router

  pipeline :api do
    plug :accepts, ["json"]
    plug :authorize
  end

  pipeline :dev do
    plug :basic_auth, username: "admin", password: "admin"
  end

  scope "/api", Web do
    pipe_through :api

    resources "/sessions", Controllers.Session, only: [:show, :create] do
      resources "/votes", Controllers.Vote, only: [:create]
      resources "/users", Controllers.User, only: [:create, :update]
      resources "/task", Controllers.Task, only: [:create, :update], singleton: true
    end
  end

  scope "/dev" do
    pipe_through [:fetch_session, :protect_from_forgery, :dev]
    live_dashboard "/dashboard", metrics: Web.Telemetry
  end

  def authorize(%{path_params: params} = conn, _) do
    # session_id =
    #   ["session_id", "id"]
    #   |> Enum.map(&Map.get(params, &1))
    #   |> Enum.find(&(not is_nil(&1)))

    # case conn |> get_req_header("authorization") |> Enum.at(0) do
    #   "Bearer " <> user_id when not is_nil(session_id) ->
    #     case Core.Session.Service.get(session_id) do
    #       {:ok, session} ->
    #         case session do
    #           %{admin: ^user_id} ->
    #             conn
    #             |> assign(:user, user_id)
    #             |> assign(:membership, :admin)

    #           %{users: %{^user_id => _}} ->
    #             conn
    #             |> assign(:user, user_id)
    #             |> assign(:membership, :member)

    #           _ ->
    #             conn
    #             |> put_status(:unauthorized)
    #             |> json(%{error: "unauthorized!"})
    #             |> halt()
    #         end

    #       _ ->
    #         conn
    #     end

    #   nil when not is_nil(session_id) ->
    #     conn
    #     |> put_status(:unauthorized)
    #     |> json(%{error: "unauthorized!"})
    #     |> halt()

    #   _ ->
    #     conn
    # end

    conn
  end
end
