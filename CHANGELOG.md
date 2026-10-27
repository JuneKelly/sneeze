# Sneeze Changelog

## 3.0.0

- Update elixir version to 1.18
- Update `ex_doc`
- **Breaking:** Attribute values are now HTML-escaped. Values that were already
  escaped by the caller will now be double-escaped.
- **Breaking:** Invalid attribute names now raise an `ArgumentError`. A name is
  invalid if it is empty (including a `nil` key), is not valid UTF-8, or
  contains ASCII whitespace, control characters, Unicode noncharacters, `"`, `'`,
  `>`, `/` or `=`.
- Boolean and `nil` attribute values now follow Hiccup: `true` repeats the
  attribute name as its value (e.g. `disabled="disabled"`), and `false` or `nil`
  omits the attribute. Previously these values raised an `ArgumentError`.
- Numbers and atoms as attribute values are now converted to strings.
  Previously integers were emitted as raw bytes (e.g. `width: 100` rendered as
  `width="d"`), and atoms raised.
- List attribute values are still treated as iodata, and are now escaped.
