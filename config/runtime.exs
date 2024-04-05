import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.
if config_env() == :prod do
  import Config

  config :web, Web.Endpoint,
    http: [
      port: System.get_env("PORT", "4000")
    ]

  # https: [
  #   cipher_suite: :strong,
  #   port: System.get_env("SSL_PORT", "443"),
  #   keyfile: System.get_env("APP_SSL_KEY_PATH"),
  #   certfile: System.get_env("APP_SSL_CERT_PATH")
  # ]

  config :core, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :web, Web.Endpoint, server: true
end
