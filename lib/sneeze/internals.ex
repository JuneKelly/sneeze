defmodule Sneeze.Internal do
  def void_tags() do
    [
      :area,
      :base,
      :br,
      :col,
      :command,
      :embed,
      :hr,
      :img,
      :input,
      :keygen,
      :link,
      :meta,
      :param,
      :source,
      :track,
      :wbr
    ]
  end

  def is_void_tag?(tag) do
    Enum.member?(void_tags(), tag)
  end

  def attributes_to_iolist(attrib_map) do
    Enum.map(attrib_map, fn {k, v} -> [" ", to_string(k), "=\"", v, "\""] end)
  end

  def render_opening_tag(tag_name) do
    ["<", to_string(tag_name), ">"]
  end

  def render_opening_tag(tag_name, attribs) do
    attrib_iolist = attributes_to_iolist(attribs)
    ["<", to_string(tag_name), attrib_iolist, ">"]
  end

  def render_closing_tag(tag_name) do
    ["</", to_string(tag_name), ">"]
  end

  def render_void_tag(tag_name) do
    ["<", to_string(tag_name), " />"]
  end

  def render_void_tag(tag_name, attribs) do
    attrib_iolist = attributes_to_iolist(attribs)
    ["<", to_string(tag_name), attrib_iolist, " ", "/>"]
  end

  def render_tag(tag) do
    [render_opening_tag(tag), render_closing_tag(tag)]
  end

  def render_tag(tag, attributes) do
    [render_opening_tag(tag, attributes), render_closing_tag(tag)]
  end
end
