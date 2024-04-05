import Config

config :web, Web.Endpoint,
  force_ssl: [hsts: true],
  url: [host: "localhost", port: System.get_env("PORT", "4000")]

config :logger, level: :info
