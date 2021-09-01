# Sneeze

[![CircleCI](https://circleci.com/gh/ShaneKilkelly/sneeze.svg?style=shield)](https://circleci.com/gh/ShaneKilkelly/sneeze)
[![Module Version](https://img.shields.io/hexpm/v/sneeze.svg)](https://hex.pm/packages/sneeze)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/sneeze/)
[![Total Download](https://img.shields.io/hexpm/dt/sneeze.svg)](https://hex.pm/packages/sneeze)
[![License](https://img.shields.io/hexpm/l/sneeze.svg)](https://github.com/JuneKelly/sneeze/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/JuneKelly/sneeze.svg)](https://github.com/JuneKelly/sneeze/commits/master)

Render Elixir data-structures to HTML. Inspired by [Hiccup](https://github.com/weavejester/hiccup).


## Installation

Sneeze is available from [Hex.pm](https://hex.pm/packages/sneeze):

```elixir
def deps do
  [
    {:sneeze, "~> 1.2"}
  ]
end
```


## Usage

The `Sneeze.render/1` function will render a list of 'nodes' to html. A node can be any of:

- A tag: `[:br]`
- A tag with a body: `[:p, "hello"]`
- A tag with attributes: `[:input, %{type: "text", class: "form-field", name: "widget-input"}]`
- A tag with attributes and a body: `[:p, %{class: "article-content"}, "hello"]`
- A bare, stringable node: `22`
- A "raw html" node, which will not be escaped: `[:__@raw_html, "<span>derp</span>"]`

Of course, the `body` of any node can be an arbitrary number of other nodes, like so:
`[:p, %{id: "status"}, [:span, "woo"]]`


## Examples

```elixir
Sneeze.render([:p %{class: "greeting"} "hello world"])
# => <p class="greeting">hello world</p>

Sneeze.render([:br])
# => <br />

Sneeze.render([:span, "<a>will be escaped</a>"])
# => <span>&lt;a&gt;will be escaped&lt;/a&gt</span>;

Sneeze.render([:div, [:__@raw_html, "<span>totally not escaped</span>"]])
# => <div><span>totally not escaped</span></div>

Sneeze.render(
  [:ul, %{class: "super-cool-list"},
   [:li,
    [:a, %{href: "/"},        "Home"]],
   [:li,
    [:a, %{href: "/about"},   "About"]],
   [:li,
    [:a, %{href: "/contact"}, "Contact"]]]
)
# => <ul class="super-cool-list"><li><a href="/">Home</a></li>...</ul

Sneeze.render([
  [:__@raw_html, "<!DOCTYPE html>"],
  [:head,
   [:title, "wat"]],
  [:body,
   [:div, %{id: "main-content"}, "hello"]]
]
# => <!DOCTYPE html><head><title>wat</title></head><body><div id="main-content">hello</div></body>
```

If you're using sneeze and getting surprising/screwy results, please [open an issue](https://github.com/ShaneKilkelly/sneeze/issues).


## Documentation

Documentation can be found on [hexdocs](https://hexdocs.pm/sneeze/).


## Demo App

See [cold](https://github.com/ShaneKilkelly/cold-sneeze) for a demo of how to use Sneeze with Plug.


## Bugs, Improvements and Contributing

Open an issue or pull-request on [GitHub](https://github.com/ShaneKilkelly/sneeze), all contributions welcome! :)


## Changes

### 1.2.0

- Add `html_entities` to application list


### 1.1.0

- Better performance, using iolists instead of string-concatination


## Copyright and License

Copyright (c) 2016 Shane Kilkelly

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the [LICENSE.md](./LICENSE.md) file for more details.
