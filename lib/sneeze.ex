defmodule Sneeze do
  alias Sneeze.Internal

  def render(data) do
    _render(data)
  end

  defp _render(data) do
    case data do
      [] ->
        ""

      # list with tag
      [tag] when is_atom(tag) ->
        Internal.render_tag(tag)

      # list with tag and attribute map
      [tag, attributes] when is_atom(tag) and is_map(attributes) ->
        Internal.render_tag(tag, attributes)

      # list with tag, attribute map and child nodes
      [tag, attributes | children] when is_map(attributes) ->
        Internal.render_opening_tag(tag, attributes)
        <> _render(children)
        <> Internal.render_closing_tag(tag)

      # list with tag and child nodes
      [tag | children] when is_atom(tag) ->
        Internal.render_opening_tag(tag)
        <> _render(children)
        <> Internal.render_closing_tag(tag)

      # list with list of child nodes
      [node] when is_list(node) ->
        _render node

      # list with sub-list as first element
      [node | rest] when is_list(node) ->
        _render(node) <> _render(rest)

      # list with single, stringible member
      [node] ->
        to_string node

      # any non-list node
      bare_node ->
        to_string bare_node

    end
  end

end
