defmodule Sneeze.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sneeze,
      version: "1.2.1",
      elixir: "~> 1.11",
      description: "Render Elixir data to HTML. Inspired by Hiccup.",
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:html_entities]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:html_entities, "~> 0.5"},
      {:ex_doc, "~> 0.29", only: :dev}
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
end
