defmodule Sneeze.Internals do

  def attributes_to_string(attrib_map) do
    Enum.map(attrib_map, fn({k,v}) -> "#{k}=\"#{v}\"" end)
    |> Enum.join(" ")
  end

  def render_opening_tag(tag_name) do
    "<#{tag_name}>"
  end
  def render_opening_tag(tag_name, attribs) do
    attrib_string = attributes_to_string(attribs)
    "<#{tag_name} #{attrib_string}>"
  end

  def render_closing_tag(tag_name) do
    "</#{tag_name}>"
  end

  def render_self_closing_tag(tag_name) do
    "<#{tag_name} />"
  end

  def render_self_closing_tag(tag_name, attribs) do
    attrib_string = attributes_to_string(attribs)
    "<#{tag_name} #{attrib_string} />"
  end


end
