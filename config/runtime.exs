import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.
IO.inspect(config_env())

if config_env() == :prod do
  import Config

  app_name =
    System.get_env("FLY_APP_NAME") ||
      raise "FLY_APP_NAME not available"

  config :web, Web.Endpoint,
    http: [
      port: System.get_env("PORT", "4000")
    ]

  config :web, Web.Endpoint, server: true

  config :libcluster,
    topologies: [
      fly6pn: [
        strategy: Cluster.Strategy.DNSPoll,
        config: [
          polling_interval: 5_000,
          node_basename: app_name,
          query: "#{app_name}.internal"
        ]
      ]
    ]
end
