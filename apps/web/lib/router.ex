defmodule Web.Router do
  use Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :authorize
  end

  scope "/api", Web do
    pipe_through :api

    resources "/sessions", Controllers.Session, only: [:show, :create] do
      resources "/votes", Controllers.Vote, only: [:create]
      resources "/users", Controllers.User, only: [:create, :update]
      resources "/task", Controllers.Task, only: [:create, :update], singleton: true
    end
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:web, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: Web.Telemetry
    end
  end

  def authorize(%{path_params: params} = conn, _) do
    session_id =
      ["session_id", "id"]
      |> Enum.map(&Map.get(params, &1))
      |> Enum.find(&(not is_nil(&1)))

    case conn |> get_req_header("authorization") |> Enum.at(0) do
      "Bearer " <> user_id when not is_nil(session_id) ->
        case Core.Session.Service.get(session_id) do
          {:ok, session} ->
            case session do
              %{admin: ^user_id} ->
                conn
                |> assign(:user, user_id)
                |> assign(:membership, :admin)

              %{users: %{^user_id => _}} ->
                conn
                |> assign(:user, user_id)
                |> assign(:membership, :member)

              _ ->
                conn
                |> put_status(:unauthorized)
                |> json(%{error: "unauthorized!"})
                |> halt()
            end

          _ ->
            conn
        end

      nil when not is_nil(session_id) ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "unauthorized!"})
        |> halt()

      _ ->
        conn
    end
  end
end
