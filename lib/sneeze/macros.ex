defmodule Sneeze.Macros do
  @moduledoc false

  defmacro define_tags_to_strings(tags) do
    quote bind_quoted: [tags: tags] do
      Enum.each(tags, fn tagname ->
         as_str = to_string(tagname)

         defp tag_to_string(unquote(tagname)) do
           unquote(as_str)
         end
      end)

      defp tag_to_string(unknown_tag), do: to_string(unknown_tag)
    end
  end
end
