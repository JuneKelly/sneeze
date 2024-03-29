defmodule Sneeze.Internal do
  require Sneeze.Macros

  Sneeze.Macros.define_tags_to_strings([
    :a,
    :div,
    :span,
    :li,
    :br,
    :p,
    :link,
    :meta,
    :td,
    :tr,
    :ul,
    :h3,
    :h2,
    :img,
    :code,
    :svg,
    :button
  ])

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
    Enum.sort(attrib_map)
    |> Enum.map(fn {k, v} -> [" ", to_string(k), "=\"", v, "\""] end)
  end

  def render_opening_tag(tag_name) do
    ["<", tag_to_string(tag_name), ">"]
  end

  def render_opening_tag(tag_name, attribs) do
    attrib_iolist = attributes_to_iolist(attribs)
    ["<", tag_to_string(tag_name), attrib_iolist, ">"]
  end

  def render_closing_tag(tag_name) do
    ["</", tag_to_string(tag_name), ">"]
  end

  def render_void_tag(tag_name) do
    ["<", tag_to_string(tag_name), " />"]
  end

  def render_void_tag(tag_name, attribs) do
    attrib_iolist = attributes_to_iolist(attribs)
    ["<", tag_to_string(tag_name), attrib_iolist, " ", "/>"]
  end

  def render_tag(tag) do
    [render_opening_tag(tag), render_closing_tag(tag)]
  end

  def render_tag(tag, attributes) do
    [render_opening_tag(tag, attributes), render_closing_tag(tag)]
  end
end
