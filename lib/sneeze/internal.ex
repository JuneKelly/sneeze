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
    |> Enum.map(fn {k, v} ->
      name = attribute_name(k)

      case v do
        v when v in [nil, false] -> []
        true -> [" ", name, "=\"", escape(name), "\""]
        _ -> [" ", name, "=\"", attribute_value(v), "\""]
      end
    end)
  end

  defp attribute_value(value) when is_list(value), do: IO.iodata_to_binary(value) |> escape()
  defp attribute_value(value), do: to_string(value) |> escape()

  def escape(string) do
    if needs_escape?(string), do: HtmlEntities.encode(string), else: string
  end

  defp needs_escape?(<<c, _::binary>>) when c in [?", ?', ?&, ?<, ?>], do: true
  defp needs_escape?(<<_, rest::binary>>), do: needs_escape?(rest)
  defp needs_escape?(<<>>), do: false

  # Attribute names can't be escaped, so reject any that would break out of the
  # name. See "Attributes" in https://html.spec.whatwg.org/multipage/syntax.html
  defp attribute_name(key) do
    name = to_string(key)

    if name != "" and valid_attribute_name?(name) do
      name
    else
      raise ArgumentError, "invalid attribute name: #{inspect(key)}"
    end
  end

  defp valid_attribute_name?(<<>>), do: true

  defp valid_attribute_name?(<<c::utf8, _::binary>>)
       when c in [?\s, ?", ?', ?>, ?/, ?=] or c < 0x20 or c in 0x7F..0x9F or
              c in 0xFDD0..0xFDEF or Bitwise.band(c, 0xFFFE) == 0xFFFE,
       do: false

  defp valid_attribute_name?(<<_::utf8, rest::binary>>), do: valid_attribute_name?(rest)
  defp valid_attribute_name?(_invalid_utf8), do: false

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
