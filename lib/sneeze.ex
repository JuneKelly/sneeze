defmodule Sneeze do
  alias Sneeze.Internals

  def render(data) do
    _render(data)
  end

  defp _render(data) do
    case data do
      [] ->
        ""
      [tag_name] ->
        Internals.render_tag(tag_name)
      [tag_name, attributes] when is_map(attributes) ->
        Internals.render_tag(tag_name, attributes)
      bare_node ->
        to_string bare_node
    end
  end

end
