defmodule ZipperTree.Mixfile do
  use Mix.Project

  @version "0.1.1"

  def project do
    [app: :zipper_tree,
     version: @version,
     elixir: "~> 1.0",
     deps: deps,
     test_coverage: [tool: Coverex.Task, coveralls: true, debug: true],
     # Hex
     description: description,
     package: package]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      applications: [:logger] ++
      case Mix.env do
        :test -> [ :dbg ]
        :dev  -> [ :reprise ]
        :prod -> []
      end
    ]
  end

  defp description do
    """
    Methods for travelsal and modification of Trees using a zipper.
    """
  end

  defp package do
    [contributors: ["Dylan Kendal"],
     licenses: ["Do What The Fuck You Want To Public License (WTFPL)"],
     links: %{"GitHub" => "https://github.com/Dkendal/zipper_tree"}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:apex, "~>0.3.2", only: :dev},
      {:reprise, "~> 0.3.0", only: :dev},
      {:coverex, "~> 1.2.0", only: :test},
      {:dbg, "~> 1.0.0", only: [:dev, :test]}
    ]
  end
end
