import Config

config :web, Web.Endpoint,
  watchers: [],
  debug_errors: true,
  check_origin: false,
  code_reloader: true,
  http: [ip: {0, 0, 0, 0}, port: System.get_env("PORT", 4000)],
  secret_key_base: "A0bWp8RHawJifQ8HPW6lGFxrboa1zil04qPAO4uzNtLu/sfd7Mcg73W0ltdSQ0ny"

config :web, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
