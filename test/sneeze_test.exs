defmodule SneezeTest do
  use ExUnit.Case
  doctest Sneeze

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "empty" do
    assert Sneeze.render([]) == ""
  end

  test "empty p tag" do
    assert Sneeze.render([:p]) == "<p></p>"
  end

  test "empty p tag with class" do
    assert Sneeze.render([:p, %{class: "foo"}]) == "<p class=\"foo\"></p>"
  end

end

defmodule SneezeInternalsTest do
  use ExUnit.Case
  doctest Sneeze.Internals

  alias Sneeze.Internals

  test "create attribute string from map" do
    attribs = %{class: "foo", id: "bar"}
    assert Internals.attributes_to_string(attribs) == "class=\"foo\" id=\"bar\""
  end

  test "empty attributes" do
    attribs = %{}
    assert Internals.attributes_to_string(attribs) == ""
  end

  test "opening tag" do
    assert Internals.render_opening_tag(:p) == "<p>"
    assert Internals.render_opening_tag(:p, %{class: "greeting"}) == "<p class=\"greeting\">"
  end

  test "closing tag" do
    assert Internals.render_closing_tag(:p) == "</p>"
  end

  test "self-closing tag" do
    assert Internals.render_self_closing_tag(:br) == "<br />"
    assert Internals.render_self_closing_tag(:br, %{class: "foo"}) == "<br class=\"foo\" />"
  end

end
