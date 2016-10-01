defmodule Sneeze do
  alias Sneeze.Internal
  alias Sneeze.RawHtml

  def render(data) do
    _render(data)
  end

  # An element is either:
  #   - [tag, attribute_map | body]
  #   - [tag, attribute_map]
  #   - [tag, body]
  #   - [tag]
  #   - %RawHtml{html: h}
  #   - bare_stringy_node
  defp _render(data) do
    case data do
      [] ->
        ""

      # list with tag
      [tag] when is_atom(tag) ->
        if Internal.is_void_tag?(tag) do
          Internal.render_void_tag(tag)
        else
          Internal.render_tag(tag)
        end

      # list with tag and attribute map
      [tag, attributes] when is_atom(tag) and is_map(attributes) ->
        if Internal.is_void_tag?(tag) do
          Internal.render_void_tag(tag, attributes)
        else
          Internal.render_tag(tag, attributes)
        end

      # list with tag, attribute map and child nodes
      [tag, attributes | body] when is_map(attributes) ->
        if Internal.is_void_tag?(tag) do
          Internal.render_void_tag(tag, attributes)
          <> _render(body)  # not actually body, next elements
        else
          Internal.render_opening_tag(tag, attributes)
          <> _render(body)
          <> Internal.render_closing_tag(tag)
        end

      # list with tag and child nodes
      [tag | body] when is_atom(tag) ->
        if Internal.is_void_tag?(tag) do
          Internal.render_void_tag(tag)
          <> _render(body)  # not actually body, next elements
        else
          Internal.render_opening_tag(tag)
          <> _render(body)
          <> Internal.render_closing_tag(tag)
        end

      # list with list of child nodes
      [node] when is_list(node) ->
        _render node

      # list with sub-list as first element
      [node | rest] when is_list(node) ->
        _render(node) <> _render(rest)

      # list with single, stringible member
      [node] ->
        to_string(node) |> HtmlEntities.encode

      # any non-list node
      bare_node ->
        to_string(bare_node) |> HtmlEntities.encode

    end
  end

end
