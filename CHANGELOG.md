# Sneeze Changelog

## 3.0.0

This is a Hiccup parity release: Sneeze now renders elements, attributes and
content the way [Hiccup](https://github.com/weavejester/hiccup) does in its
default (xhtml) mode, and is safe by default. Several changes are breaking.

### Breaking changes

- Attribute values are now HTML-escaped. Values that were already escaped by
  the caller will now be double-escaped.
- The content of `:script` and `:style` tags is now HTML-escaped, like all
  other content, so that it can't close the tag early. Wrap trusted scripts and
  styles in `:__@raw_html`: `[:script, [:__@raw_html, "..."]]`.
- List attribute values are now joined with spaces (`class: ["a", "b"]` renders
  `class="a b"`). Previously they were treated as iodata and concatenated.
  Charlists are lists of integers, so they now render as space-separated
  numbers; convert them with `to_string/1` first.
- Invalid attribute names now raise an `ArgumentError`. A name is invalid if it
  is empty (including a `nil` key), is not valid UTF-8, or contains ASCII
  whitespace, control characters, Unicode noncharacters, `"`, `'`, `>`, `/` or
  `=`.
- Invalid tag names now raise an `ArgumentError`. A tag name must start with an
  ASCII letter, and otherwise follows the same rules as attribute names.
- `#` and `.` in tag names are now parsed as id and class shorthand (see
  below), rather than rendered as part of the tag name. Shorthand with classes
  before the id (`:"div.a#b"`) raises an `ArgumentError`.

### New features

- Hiccup-style tag shorthand: `[:"div#main.wide.dark"]` renders
  `<div class="wide dark" id="main"></div>`. An `:id` in the attribute map takes
  precedence over the shorthand id, and shorthand classes come before any
  `:class` in the attribute map.
- Map attribute values are rendered as styles: `style: %{color: "red"}` renders
  `style="color:red;"`, with keys sorted.
- Streams, ranges and other non-list enumerables can be used as child nodes,
  and are rendered like lists. Structs are no longer mistaken for attribute
  maps.
- Boolean and `nil` attribute values: `true` repeats the attribute name as its
  value (`disabled="disabled"`), and `false` or `nil` omits the attribute.
  Previously these values raised an `ArgumentError`.
- Numbers and atoms as attribute values are converted to strings. Previously
  integers were emitted as raw bytes (`width: 100` rendered as `width="d"`), and
  atoms raised.

### Other changes

- Update elixir version to 1.18
- Update `ex_doc`
