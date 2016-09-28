defmodule Sneeze.Internals do

  def attributes_to_string(attrib_map) do
    Enum.map(attrib_map, fn({k,v}) -> "#{k}=\"#{v}\"" end)
    |> Enum.join(" ")
  end

  def render_tag(data) do
    ""
  end

end
