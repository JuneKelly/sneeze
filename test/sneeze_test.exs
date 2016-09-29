defmodule SneezeTest do
  use ExUnit.Case
  doctest Sneeze

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "just a string" do
    assert Sneeze.render("wat") ==
      "wat"
  end

  test "just a number" do
    assert Sneeze.render(42) ==
      "42"
  end

  test "empty" do
    assert Sneeze.render([]) ==
      ""
  end

  test "empty p tag" do
    assert Sneeze.render([:p]) ==
      "<p></p>"
  end

  test "empty p tag with class" do
    assert Sneeze.render([:p, %{class: "foo"}]) ==
      "<p class=\"foo\"></p>"
  end

end

defmodule SneezeInternalTest do
  use ExUnit.Case
  doctest Sneeze.Internal

  alias Sneeze.Internal

  test "create attribute string from map" do
    assert Internal.attributes_to_string(%{class: "foo", id: "bar"}) ==
      "class=\"foo\" id=\"bar\""
  end

  test "empty attributes" do
    assert Internal.attributes_to_string(%{}) ==
      ""
  end

  test "opening tag" do
    assert Internal.render_opening_tag(:p) ==
      "<p>"
    assert Internal.render_opening_tag(:p, %{class: "greeting"}) ==
      "<p class=\"greeting\">"
  end

  test "closing tag" do
    assert Internal.render_closing_tag(:p) ==
      "</p>"
  end

  test "self-closing tag" do
    assert Internal.render_self_closing_tag(:br) ==
      "<br />"
    assert Internal.render_self_closing_tag(:br, %{class: "foo"}) ==
      "<br class=\"foo\" />"
  end

end
