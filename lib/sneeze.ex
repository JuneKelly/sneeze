defmodule Sneeze do
  alias Sneeze.Internal

  @doc ~s"""
  Render a data-structure, containing 'elements' to html.
  An element is either:
  - [tag, attribute_map | body]
  - [tag, attribute_map]
  - [tag | body]
  - [tag]
  - [:@__raw_html, html_string]
  - [:script, attribute_map, script_text]
  - [:script, script_text]
  - [:style, attribute_map, style_text]
  - [:style, style_text]
  - A bare, stringable value (such as a string or number)
  - A list of elements

  The content of `:__@raw_html`, `:style` and `:script` elements will not be escaped.
  All other elements content will be html-escaped.

  Examples:
  ```
  render([:p, %{class: "outlined"}, "hello"])
  render([:br])
  render([[:span, "one"], [:span, %{class: "highlight"}, "two"]])
  render([:ul, %{id: "some-list"},
          [:li, [:a, %{href: "/"},      "Home"]],
          [:li, [:a, %{href: "/about"}, "About"]]])
  render([:__@raw_html, "<!DOCTYPE html>"])
  render([:script, "console.log(42 < 9);"])
  ```
  """
  def render(data) do
    # _render(data)
    IO.iodata_to_binary(_render(data))
  end

  defp _render(data) do
    case data do
      [] ->
        []

      # list with tag
      [tag] when is_atom(tag) ->
        if Internal.is_void_tag?(tag) do
          [Internal.render_void_tag(tag)]
        else
          [Internal.render_tag(tag)]
        end

      # script tags
      [:script, attributes, script_body] when is_map(attributes) ->
        [
          Internal.render_opening_tag(:script, attributes),
          script_body,
          Internal.render_closing_tag(:script)
        ]

      [:script, script_body] ->
        [Internal.render_opening_tag(:script), script_body, Internal.render_closing_tag(:script)]

      # style tags
      [:style, attributes, style_body] when is_map(attributes) ->
        [
          Internal.render_opening_tag(:style, attributes),
          style_body,
          Internal.render_closing_tag(:style)
        ]

      [:style, style_body] ->
        [Internal.render_opening_tag(:style), style_body, Internal.render_closing_tag(:style)]

      # list with tag and attribute map
      [tag, attributes] when is_atom(tag) and is_map(attributes) ->
        if Internal.is_void_tag?(tag) do
          [Internal.render_void_tag(tag, attributes)]
        else
          [Internal.render_tag(tag, attributes)]
        end

      [:__@raw_html, html_string] ->
        [html_string]

      # list with tag, attribute map and child nodes
      [tag, attributes | body] when is_map(attributes) ->
        if Internal.is_void_tag?(tag) do
          [
            Internal.render_void_tag(tag, attributes),
            # not actually body, next elements
            _render(body)
          ]
        else
          [
            Internal.render_opening_tag(tag, attributes),
            _render_body(body),
            Internal.render_closing_tag(tag)
          ]
        end

      # list with tag and child nodes
      [tag | body] when is_atom(tag) ->
        if Internal.is_void_tag?(tag) do
          [
            Internal.render_void_tag(tag),
            # not actually body, next elements
            _render_body(body)
          ]
        else
          [Internal.render_opening_tag(tag), _render_body(body), Internal.render_closing_tag(tag)]
        end

      # list with list of child nodes
      [node] when is_list(node) ->
        [_render(node)]

      # list with sub-list as first element
      [node | rest] when is_list(node) ->
        [_render(node), _render(rest)]

      # list with single, stringible member
      [something] ->
        [to_string(something) |> HtmlEntities.encode()]

      # any non-list node
      bare_node ->
        [to_string(bare_node) |> HtmlEntities.encode()]
    end
  end

  defp _render_body(body_elements) do
    body_elements
    |> Enum.map(&_render/1)
  end
end
