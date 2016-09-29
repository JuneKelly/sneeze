# Sneeze

Render Elixir data-structures to HTML. Inspired by [Hiccup](https://github.com/weavejester/hiccup).


## Examples

```elixir
Sneeze.render([:p %{class: "greeting"} "hello world"])
# => "<p class=\"greeting\">hello world</p>"
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `sneeze` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:sneeze, "~> 0.1.0"}]
    end
    ```

  2. Ensure `sneeze` is started before your application:

    ```elixir
    def application do
      [applications: [:sneeze]]
    end
    ```
