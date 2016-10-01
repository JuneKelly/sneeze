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

  test "escape some html" do
    assert Sneeze.render("<a>derp</a>") == "&lt;a&gt;derp&lt;/a&gt;"
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

  test "br tag" do
    assert Sneeze.render([:br]) ==
      "<br />"
  end

  test "br tag with id" do
    assert Sneeze.render([:br, %{id: "why-would-a-br-have-an-id"}]) ==
      "<br id=\"why-would-a-br-have-an-id\" />"
  end

  test "two p and a br" do
    assert Sneeze.render([[:p], [:br], [:p]]) ==
      "<p></p><br /><p></p>"
  end

  test "p with two bare :br's inside, should render 'brbr'" do
    assert Sneeze.render([:p, %{class: "wrapper"}, :br, :br]) ==
      "<p class=\"wrapper\">brbr</p>"
  end

  test "p with a br and span inside" do
    assert Sneeze.render([:p, %{class: "wrapper"}, [:br], [:br], [:p]]) ==
      "<p class=\"wrapper\"><br /><br /><p></p></p>"
  end

  test "empty p tag with class" do
    assert Sneeze.render([:p, %{class: "foo"}]) ==
      "<p class=\"foo\"></p>"
  end

  test "p tag with class and text" do
    assert Sneeze.render([:p, %{class: "foo"}, "hello world"]) ==
      "<p class=\"foo\">hello world</p>"
  end

  test "ul with id, and li elements" do
    data = [:ul, %{id: "my-list"},
            [:li, "one"],
            [:li, "two"]]
    assert Sneeze.render(data) ==
      "<ul id=\"my-list\"><li>one</li><li>two</li></ul>"
  end

  test "ul with li and a elements" do
    data = [:ul,
            [:li, [:a, %{href: "x"}, "one"]],
            [:li, [:a, %{href: "y"}, "two"]]]
    assert Sneeze.render(data) ==
      "<ul><li><a href=\"x\">one</a></li><li><a href=\"y\">two</a></li></ul>"
  end

  test "p with embedded raw html" do
    data = [
      :p, %{id: "wat"},
      [:br],
      [:__@raw_html, "<span>test</span>"],
      [:br]
    ]
    assert Sneeze.render(data) ==
      "<p id=\"wat\"><br /><span>test</span><br /></p>"
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
    assert Internal.render_void_tag(:br) ==
      "<br />"
    assert Internal.render_void_tag(:br, %{class: "foo"}) ==
      "<br class=\"foo\" />"
  end

end
