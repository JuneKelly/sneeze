defmodule Sneeze do
  alias Sneeze.Internals

  def render(data) do
    case data do
      [] ->
        ""
      [tag_name] ->
        Internals.render_tag(tag_name)
      [tag_name, attributes] when is_map(attributes) ->
        Internals.render_tag(tag_name, attributes)
      node ->
        to_string node
    end
  end

end
