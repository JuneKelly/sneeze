defmodule SneezeTest do
  use ExUnit.Case
  doctest Sneeze

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "just a string" do
    assert Sneeze.render("wat") == "wat"
  end

  test "escape some html" do
    assert Sneeze.render("<a>derp</a>") == "&lt;a&gt;derp&lt;/a&gt;"
  end

  test "just a number" do
    assert Sneeze.render(42) == "42"
  end

  test "empty data" do
    assert Sneeze.render([]) == ""
    assert Sneeze.render(nil) == ""
  end

  test "empty p tag" do
    assert Sneeze.render([:p]) == "<p></p>"
  end

  test "a sequence of tags" do
    assert Sneeze.render([[:p, %{class: "a"}], [:p, %{class: "b"}]]) ==
             "<p class=\"a\"></p><p class=\"b\"></p>"
  end

  test "a html document" do
    data = [
      [:__@raw_html, "<!DOCTYPE html>"],
      [:head, [:title, "wat"]],
      [:body, [:div, %{id: "main-content"}, "hello"]]
    ]

    assert Sneeze.render(data) ==
             "<!DOCTYPE html><head><title>wat</title></head>" <>
               "<body><div id=\"main-content\">hello</div></body>"
  end

  test "br tag" do
    assert Sneeze.render([:br]) == "<br />"
  end

  test "br tag with id" do
    assert Sneeze.render([:br, %{id: "why-would-a-br-have-an-id"}]) ==
             "<br id=\"why-would-a-br-have-an-id\" />"
  end

  test "two p and a br" do
    assert Sneeze.render([[:p], [:br], [:p]]) == "<p></p><br /><p></p>"
  end

  test "p with two bare :br's inside, should render 'brbr'" do
    assert Sneeze.render([:p, %{class: "wrapper"}, :br, :br]) == "<p class=\"wrapper\">brbr</p>"
  end

  test "p with a br and span inside" do
    assert Sneeze.render([:p, %{class: "wrapper"}, [:br], [:br], [:p]]) ==
             "<p class=\"wrapper\"><br /><br /><p></p></p>"
  end

  test "empty p tag with class" do
    assert Sneeze.render([:p, %{class: "foo"}]) == "<p class=\"foo\"></p>"
  end

  test "p tag with class and text" do
    assert Sneeze.render([:p, %{class: "foo"}, "hello world"]) ==
             "<p class=\"foo\">hello world</p>"
  end

  test "ul with id, and li elements" do
    data = [:ul, %{id: "my-list"}, [:li, "one"], [:li, "two"]]
    assert Sneeze.render(data) == "<ul id=\"my-list\"><li>one</li><li>two</li></ul>"
  end

  test "ul with li and a elements" do
    data = [:ul, [:li, [:a, %{href: "x"}, "one"]], [:li, [:a, %{href: "y"}, "two"]]]

    assert Sneeze.render(data) ==
             "<ul><li><a href=\"x\">one</a></li><li><a href=\"y\">two</a></li></ul>"
  end

  test "p with embedded raw html" do
    data = [
      :p,
      %{id: "wat"},
      [:br],
      [:__@raw_html, "<span>test</span>"],
      [:br]
    ]

    assert Sneeze.render(data) == "<p id=\"wat\"><br /><span>test</span><br /></p>"
  end

  test "a script tag" do
    data = [:script, "console.log(42 < 9);"]
    assert Sneeze.render(data) == "<script>console.log(42 < 9);</script>"
  end

  test "a style tag" do
    data = [:style, ".foo > .bar { color: pink; }"]
    assert Sneeze.render(data) == "<style>.foo > .bar { color: pink; }</style>"
  end

  test "some unicode" do
    data = [:span, %{class: "lol 🐜"}, "Hello ◊"]
    assert Sneeze.render(data) == "<span class=\"lol 🐜\">Hello ◊</span>"
  end

  test "render_iodata, empty data" do
    assert Sneeze.render_iodata([]) == []
    assert Sneeze.render_iodata(nil) == [""]
  end

  test "render_iodata, small example" do
    data = [:a, %{href: "example.com"}, "hello"]

    assert Sneeze.render_iodata(data) == [
             ["<", "a", [[" ", "href", "=\"", "example.com", "\""]], ">"],
             [["hello"]],
             ["</", "a", ">"]
           ]
  end

  test "render_iodata, larger example" do
    data = [
      :div,
      [
        [:span, %{class: "something"}, "hello"],
        [:a, %{href: "example.com"}, "a link"]
      ]
    ]

    assert Sneeze.render_iodata(data) == [
             ["<", "div", ">"],
             [
               [
                 [
                   ["<", "span", [[" ", "class", "=\"", "something", "\""]], ">"],
                   [["hello"]],
                   ["</", "span", ">"]
                 ],
                 [
                   [
                     ["<", "a", [[" ", "href", "=\"", "example.com", "\""]], ">"],
                     [["a link"]],
                     ["</", "a", ">"]
                   ]
                 ]
               ]
             ],
             ["</", "div", ">"]
           ]
  end

  test "render_iodata, with embedded html" do
    data = [
      :p,
      %{id: "wat"},
      [:br],
      [:__@raw_html, "<span>test</span>"],
      [:br]
    ]

    assert Sneeze.render_iodata(data) == [
             ["<", "p", [[" ", "id", "=\"", "wat", "\""]], ">"],
             [[["<", "br", " />"]], ["<span>test</span>"], [["<", "br", " />"]]],
             ["</", "p", ">"]
           ]
  end
end

defmodule SneezeInternalTest do
  use ExUnit.Case
  doctest Sneeze.Internal

  alias Sneeze.Internal

  test "create attribute string from map" do
    assert Internal.attributes_to_iolist(%{class: "foo", id: "bar"}) ==
             [[" ", "class", "=\"", "foo", "\""], [" ", "id", "=\"", "bar", "\""]]
  end

  test "empty attributes" do
    assert Internal.attributes_to_iolist(%{}) == []
  end

  test "opening tag" do
    assert Internal.render_opening_tag(:p) == ["<", "p", ">"]

    assert Internal.render_opening_tag(:p, %{class: "greeting"}) ==
             ["<", "p", [[" ", "class", "=\"", "greeting", "\""]], ">"]
  end

  test "closing tag" do
    assert Internal.render_closing_tag(:p) == ["</", "p", ">"]
  end

  test "self-closing tag" do
    assert Internal.render_void_tag(:br) == ["<", "br", " />"]

    assert Internal.render_void_tag(:br, %{class: "foo"}) ==
             ["<", "br", [[" ", "class", "=\"", "foo", "\""]], " ", "/>"]
  end
end
