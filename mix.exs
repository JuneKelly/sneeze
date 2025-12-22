defmodule Sneeze.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sneeze,
      version: "3.0.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),

      # Docs
      name: "Sneeze",
      source_url: "https://github.com/JuneKelly/sneeze",
      homepage_url: "https://github.com/JuneKelly/sneeze",
      docs: &docs/0
    ]
  end

  def application do
    [
      extra_applications: [:logger, :html_entities]
    ]
  end

  defp package do
    [
      name: :sneeze,
      maintainers: ["June Kelly"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/JuneKelly/sneeze"}
    ]
  end

  defp deps do
    [
      {:html_entities, "~> 0.5"},
      {:ex_doc, "~> 0.39", only: :dev, runtime: false, warn_if_outdated: true}
    ]
  end

  defp docs do
    [
      main: "Sneeze",
      # logo: "path/to/logo.png",
      extras: ["README.md"]
    ]
  end
end
