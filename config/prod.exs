import Config

config :web, Web.Endpoint,
  url: [host: "localhost", port: System.get_env("PORT", "4000")]

config :logger, level: :info
