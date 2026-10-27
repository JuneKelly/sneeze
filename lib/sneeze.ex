defmodule Sneeze do
  alias Sneeze.Internal

  # Structs are maps, but are never attributes (they may be enumerable children)
  defguardp is_attributes(term) when is_map(term) and not is_struct(term)

  @doc ~s"""
  Render a data-structure, containing 'elements' to html.
  An element is either:
  - [tag, attribute_map | body]
  - [tag, attribute_map]
  - [tag | body]
  - [tag]
  - [:__@raw_html, html_string]
  - A bare, stringable value (such as a string or number)
  - A list of elements, or another enumerable such as a stream or range

  A tag may use Hiccup-style shorthand for its id and classes:
  `:"div#main.wide.dark"` renders as `<div class="wide dark" id="main">`.
  An `:id` in the attribute map takes precedence over the shorthand id, and
  shorthand classes come before any `:class` in the attribute map. Invalid tag
  names raise an `ArgumentError`.

  The content of `:__@raw_html` elements will not be escaped. All other content
  is html-escaped, including the content of `:script` and `:style` elements, so
  wrap trusted scripts and styles in `:__@raw_html`:
  `[:script, [:__@raw_html, "console.log(42 < 9);"]]`.

  Attribute values are html-escaped. A `true` value repeats the attribute name
  (`disabled="disabled"`), and a `false` or `nil` value omits the attribute.
  Lists are joined with spaces (`class: ["a", "b"]` renders `class="a b"`), and
  maps are rendered as styles (`style: %{color: "red"}` renders
  `style="color:red;"`). Invalid attribute names raise an `ArgumentError`.

  Examples:
  ```
  render([:p, %{class: "outlined"}, "hello"])
  render([:br])
  render([[:span, "one"], [:span, %{class: "highlight"}, "two"]])
  render([:ul, %{id: "some-list"},
          [:li, [:a, %{href: "/"},      "Home"]],
          [:li, [:a, %{href: "/about"}, "About"]]])
  render([:__@raw_html, "<!DOCTYPE html>"])
  render([:script, [:__@raw_html, "console.log(42 < 9);"]])
  render([:"ul#nav.menu", Stream.map(["a", "b"], &[:li, &1])])
  ```
  """
  def render(data) do
    _render(data)
    |> IO.iodata_to_binary()
  end

  @doc ~s"""
  Render a data-structure, containing 'elements' to an iodata list.
  This can be more performant than `render/1` if you are passing the result to a function that takes iodata.

  Example:
  ```
  render_iodata([:a, %{href: "example.com"}, "hello"])
  # becomes...
  [
    ["<", "a", [[" ", "href", "=\"", "example.com", "\""]], ">"],
    [["hello"]],
    ["</", "a", ">"]
  ]
  ```
  """
  def render_iodata(data) do
    _render(data)
  end

  defp _render(data) do
    case data do
      [] ->
        []

      # list with tag
      [tag] when is_atom(tag) ->
        {name, attributes} = Internal.resolve_tag(tag, nil)

        if Internal.is_void_tag?(name) do
          [void_tag(name, attributes)]
        else
          [empty_tag(name, attributes)]
        end

      # list with tag and attribute map
      [tag, attributes] when is_atom(tag) and is_attributes(attributes) ->
        {name, attributes} = Internal.resolve_tag(tag, attributes)

        if Internal.is_void_tag?(name) do
          [Internal.render_void_tag(name, attributes)]
        else
          [Internal.render_tag(name, attributes)]
        end

      [:__@raw_html, html_string] ->
        [html_string]

      # list with tag, attribute map and child nodes
      [tag, attributes | body] when is_attributes(attributes) ->
        {name, attributes} = Internal.resolve_tag(tag, attributes)

        if Internal.is_void_tag?(name) do
          [
            Internal.render_void_tag(name, attributes),
            # not actually body, next elements
            _render(body)
          ]
        else
          [
            Internal.render_opening_tag(name, attributes),
            _render_body(body),
            Internal.render_closing_tag(name)
          ]
        end

      # list with tag and child nodes
      [tag | body] when is_atom(tag) ->
        {name, attributes} = Internal.resolve_tag(tag, nil)

        if Internal.is_void_tag?(name) do
          [
            void_tag(name, attributes),
            # not actually body, next elements
            _render_body(body)
          ]
        else
          [opening_tag(name, attributes), _render_body(body), Internal.render_closing_tag(name)]
        end

      # list with list of child nodes
      [node] when is_list(node) ->
        [_render(node)]

      # list with sub-list as first element
      [node | rest] when is_list(node) ->
        [_render(node), _render(rest)]

      # list with enumerable (stream, range) or stringible struct as first element
      [node | rest] when is_struct(node) or is_function(node, 2) ->
        [render_bare_node(node), _render(rest)]

      # list with single, stringible member
      [something] ->
        [render_bare_node(something)]

      # any non-list node
      bare_node ->
        [render_bare_node(bare_node)]
    end
  end

  defp _render_body(body_elements) do
    body_elements
    |> Enum.map(&_render/1)
  end

  # Streams, ranges and other non-list enumerables are rendered like a list of
  # nodes, as Hiccup does with lazy sequences.
  defp render_bare_node(node) when is_struct(node) or is_function(node, 2) do
    if Enumerable.impl_for(node) do
      Enum.map(node, &_render/1)
    else
      to_string(node) |> Internal.escape()
    end
  end

  defp render_bare_node(node), do: to_string(node) |> Internal.escape()

  defp void_tag(name, nil), do: Internal.render_void_tag(name)
  defp void_tag(name, attributes), do: Internal.render_void_tag(name, attributes)

  defp empty_tag(name, nil), do: Internal.render_tag(name)
  defp empty_tag(name, attributes), do: Internal.render_tag(name, attributes)

  defp opening_tag(name, nil), do: Internal.render_opening_tag(name)
  defp opening_tag(name, attributes), do: Internal.render_opening_tag(name, attributes)
end
