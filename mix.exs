defmodule PlanningPoker.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      deps: deps(),
      version: "0.1.0",
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      releases: [
        app: [
          applications: [
            web: :permanent,
            core: :permanent
          ]
        ]
      ]
    ]
  end

  defp deps do
    []
  end


  defp aliases do
    [
      setup: ["cmd mix setup"]
    ]
  end
end
