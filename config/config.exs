import Config

config :web,
  generators: [context_app: :core]

config :web, Web.Endpoint,
  server: true,
  url: [host: "localhost"],
  pubsub_server: Core.PubSub,
  adapter: Bandit.PhoenixAdapter,
  live_view: [signing_salt: "WVoLwdXS"],
  render_errors: [formats: [json: Web.ErrorJSON], layout: false]

config :logger, :console,
  metadata: [:request_id],
  format: "$time $metadata[$level] $message\n"

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
