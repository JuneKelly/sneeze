defmodule Sneeze.Internal do
  require Sneeze.Macros

  # Common tags, which skip shorthand parsing and validation when rendered
  @known_tags [
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
    :button,
    :html,
    :head,
    :body,
    :title,
    :script,
    :style,
    :table,
    :thead,
    :tbody,
    :th,
    :ol,
    :h1,
    :h4,
    :section,
    :article,
    :header,
    :footer,
    :nav,
    :main,
    :form,
    :label,
    :input,
    :select,
    :option,
    :textarea,
    :strong,
    :em,
    :pre,
    :hr
  ]

  Sneeze.Macros.define_tags_to_strings(@known_tags)

  @void_tags [
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

  @void_tag_names Enum.map(@void_tags, &Atom.to_string/1)

  def void_tags(), do: @void_tags

  def is_void_tag?(tag) when tag in @void_tags or tag in @void_tag_names, do: true
  def is_void_tag?(_tag), do: false

  # Returns the tag's name and attributes, expanding Hiccup-style shorthand
  # (`:"div#main.wide"`) into id and class attributes. `attributes` may be nil,
  # and stays nil if the tag has no shorthand.
  def resolve_tag(tag, attributes) when tag in @known_tags, do: {tag_to_string(tag), attributes}

  def resolve_tag(tag, attributes) when is_atom(tag) or is_binary(tag) do
    {name, id, classes} = parse_tag(to_string(tag))

    unless valid_tag_name?(name) do
      raise ArgumentError, "invalid tag name: #{inspect(tag)}"
    end

    {name, merge_shorthand(attributes, id, classes)}
  end

  def resolve_tag(tag, _attributes), do: raise(ArgumentError, "invalid tag name: #{inspect(tag)}")

  # Mirrors Hiccup's parse-tag: a "#" or "." at the start of the tag is not
  # shorthand, and the id must come before the classes.
  defp parse_tag(tag) do
    id_index = shorthand_index(tag, "#")
    class_index = shorthand_index(tag, ".")

    cond do
      id_index && class_index && class_index < id_index ->
        raise ArgumentError, "invalid tag, the id must come before classes: #{inspect(tag)}"

      id_index && class_index ->
        {binary_part(tag, 0, id_index),
         binary_part(tag, id_index + 1, class_index - id_index - 1),
         shorthand_classes(tag, class_index)}

      id_index ->
        {binary_part(tag, 0, id_index), binary_slice(tag, (id_index + 1)..-1//1), nil}

      class_index ->
        {binary_part(tag, 0, class_index), nil, shorthand_classes(tag, class_index)}

      true ->
        {tag, nil, nil}
    end
  end

  # Returns nil when the character is absent or at the start of the tag.
  defp shorthand_index(tag, char) do
    case :binary.match(tag, char) do
      {index, _} when index > 0 -> index
      _ -> nil
    end
  end

  defp shorthand_classes(tag, class_index) do
    tag |> binary_slice((class_index + 1)..-1//1) |> String.replace(".", " ")
  end

  # Tag names must start with an ASCII letter (otherwise "<" is parsed as text),
  # and can't contain anything that would end the name.
  defp valid_tag_name?(<<c, _::binary>> = name) when c in ?a..?z or c in ?A..?Z,
    do: valid_attribute_name?(name)

  defp valid_tag_name?(_name), do: false

  defp merge_shorthand(attributes, nil, nil), do: attributes

  defp merge_shorthand(attributes, id, classes) do
    (attributes || %{})
    |> merge_shorthand_id(id)
    |> merge_shorthand_classes(classes)
  end

  defp merge_shorthand_id(attributes, nil), do: attributes

  defp merge_shorthand_id(attributes, id) do
    Map.update(attributes, attribute_key(attributes, :id), id, &(&1 || id))
  end

  defp merge_shorthand_classes(attributes, nil), do: attributes

  defp merge_shorthand_classes(attributes, classes) do
    Map.update(
      attributes,
      attribute_key(attributes, :class),
      classes,
      &merge_classes(&1, classes)
    )
  end

  # Use the string key if the attributes already have one, so the shorthand
  # doesn't produce a duplicate attribute.
  defp attribute_key(attributes, key) do
    string_key = Atom.to_string(key)
    if Map.has_key?(attributes, string_key), do: string_key, else: key
  end

  defp merge_classes(class, classes) when class in [nil, false], do: classes

  defp merge_classes(class, classes) when is_list(class) do
    classes <> " " <> (class |> Enum.reject(&is_nil/1) |> Enum.map_join(" ", &to_string/1))
  end

  defp merge_classes(class, classes), do: classes <> " " <> to_string(class)

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

  # As in Hiccup, lists are joined with spaces and maps are rendered as styles.
  defp attribute_value(value) when is_list(value) do
    Enum.map_join(value, " ", &to_string/1) |> escape()
  end

  defp attribute_value(value) when is_map(value) and not is_struct(value) do
    value
    |> Enum.map(fn {k, v} -> {to_string(k), to_string(v)} end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map_join(fn {k, v} -> k <> ":" <> v <> ";" end)
    |> escape()
  end

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
