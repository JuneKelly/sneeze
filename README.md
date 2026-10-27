# Sneeze

Render Elixir data-structures to HTML. Inspired by [Hiccup](https://github.com/weavejester/hiccup).

## Installation

Sneeze is available from [Hex.pm](https://hex.pm/packages/sneeze):

```elixir
def deps do
  [{:sneeze, "~> 3.0"}]
end
```


## Usage

The `Sneeze.render/1` function will render a list of 'nodes' to html. A node can be any of:

- A tag: `[:br]`
- A tag with a body: `[:p, "hello"]`
- A tag with attributes: `[:input, %{type: "text", class: "form-field", name: "widget-input"}]`
- A tag with attributes and a body: `[:p, %{class: "article-content"}, "hello"]`
- A tag with Hiccup-style id and class shorthand: `[:"div#main.wide.dark", "hello"]`
- A bare, stringable node: `22`
- A "raw html" node, which will not be escaped: `[:__@raw_html, "<span>derp</span>"]`
- A list of nodes, or another enumerable such as a stream or range: `Stream.map(items, &[:li, &1])`

Of course, the `body` of any node can be an arbitrary number of other nodes, like so:
`[:p, %{id: "status"}, [:span, "woo"]]`

All content is html-escaped except `:__@raw_html` nodes. This includes the content of `:script` and `:style` tags, so wrap trusted scripts and styles in `:__@raw_html`: `[:script, [:__@raw_html, "console.log(42 < 9);"]]`.

Tag shorthand expands to `id` and `class` attributes. An `:id` in the attribute map takes precedence over the shorthand id, and shorthand classes come before any `:class` in the attribute map. Invalid tag names (such as `:"p onclick=alert(1)"`) raise an `ArgumentError`.

Attribute values are html-escaped. A `true` value repeats the attribute name (`[:input, %{disabled: true}]` becomes `<input disabled="disabled" />`), and a `false` or `nil` value omits the attribute. Lists are joined with spaces (`class: ["a", "b"]` becomes `class="a b"`), and maps are rendered as styles (`style: %{color: "red"}` becomes `style="color:red;"`). Invalid attribute names (such as `"x onclick"`) raise an `ArgumentError`.

The `Sneeze.render_iodata/1` function returns an iodata list, which can be more performant in cases where you are passing the result to a function that accepts iodata.


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

Sneeze.render([:script, [:__@raw_html, "console.log(42 < 9);"]])
# => <script>console.log(42 < 9);</script>

Sneeze.render([:"div#main.wide", %{class: ["dark", "tall"], style: %{color: "red"}}, "hi"])
# => <div class="wide dark tall" id="main" style="color:red;">hi</div>

Sneeze.render([:ul, Stream.map(1..2, &[:li, &1])])
# => <ul><li>1</li><li>2</li></ul>

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

Sneeze.render_iodata([:a, %{href: "example.com"}, "hello"])
# => [
#      ["<", "a", [[" ", "href", "=\"", "example.com", "\""]], ">"],
#      [["hello"]],
#      ["</", "a", ">"]
#    ]
```

If you're using sneeze and getting surprising/screwy results, please [open an issue](https://github.com/JuneKelly/sneeze/issues).


## Documentation

Documentation can be found on [hexdocs](https://hexdocs.pm/sneeze/).


## Demo App

See [cold](https://github.com/JuneKelly/cold-sneeze) for a demo of how to use Sneeze with Plug.


## Bugs, Improvements and Contributing

Open an issue or pull-request on [GitHub](https://github.com/JuneKelly/sneeze), all contributions welcome! :)


## Changes

### 2.0.0

- Improved performance! (https://github.com/JuneKelly/sneeze/pull/19)
- Attributes are now sorted before being rendered. This fixes an issue found when upgrading to OTP 26 (https://github.com/JuneKelly/sneeze/issues/17)


### 1.3.0

- A new `Sneeze.render_iodata/1` function
- Various modernizations, dependency upgrades


### 1.2.1

- Upgrade `html_entities`


### 1.2.0

- Add `html_entities` to application list


### 1.1.0

- Better performance, using iolists instead of string-concatination
