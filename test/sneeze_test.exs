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
    assert Sneeze.render(data) == "<script>console.log(42 &lt; 9);</script>"

    data = [:script, [:__@raw_html, "console.log(42 < 9);"]]
    assert Sneeze.render(data) == "<script>console.log(42 < 9);</script>"
  end

  test "a style tag" do
    data = [:style, ".foo > .bar { color: pink; }"]
    assert Sneeze.render(data) == "<style>.foo &gt; .bar { color: pink; }</style>"

    data = [:style, [:__@raw_html, ".foo > .bar { color: pink; }"]]
    assert Sneeze.render(data) == "<style>.foo > .bar { color: pink; }</style>"
  end

  test "script content can't close the script tag" do
    data = [:script, "var s = \"</script><img src=x onerror=alert(1)>\";"]

    assert Sneeze.render(data) ==
             "<script>var s = &quot;&lt;/script&gt;&lt;img src=x onerror=alert(1)&gt;&quot;;</script>"
  end

  test "some unicode" do
    data = [:span, %{class: "lol 🐜"}, "Hello ◊"]
    assert Sneeze.render(data) == "<span class=\"lol 🐜\">Hello ◊</span>"
  end

  test "attribute values are escaped" do
    data = [:a, %{href: "x\" onclick=\"alert('<hi>&')"}, "link"]

    assert Sneeze.render(data) ==
             "<a href=\"x&quot; onclick=&quot;alert(&#39;&lt;hi&gt;&amp;&#39;)\">link</a>"
  end

  test "invalid attribute names raise" do
    for name <- [
          "x onclick",
          "x=\"\"",
          "a\"b",
          "a=b",
          "a/b",
          "a>b",
          "a'b",
          "a\tb",
          "a\nb",
          <<?a, 0x1F>>,
          "a\x7Fb",
          <<?a, 0x85::utf8>>,
          <<?a, 0x9F::utf8>>,
          <<?a, 0xFDD0::utf8>>,
          <<?a, 0xFDEF::utf8>>,
          <<?a, 0xFFFE::utf8>>,
          <<?a, 0x1FFFF::utf8>>,
          "",
          nil,
          <<0xFF>>
        ] do
      assert_raise ArgumentError, ~r/invalid attribute name/, fn ->
        Sneeze.render([:p, %{name => "y"}, "hi"])
      end
    end
  end

  test "unusual but valid attribute names are allowed" do
    data = [:div, %{"data-x" => "1", "@click" => "go", "x:lang" => "en", "ünï" => "2"}]

    assert Sneeze.render(data) ==
             "<div @click=\"go\" data-x=\"1\" x:lang=\"en\" ünï=\"2\"></div>"
  end

  test "characters just outside the rejected ranges are allowed in names" do
    for name <- [
          "a!b",
          "a~b",
          <<?a, 0xA0::utf8>>,
          <<?a, 0xFDCF::utf8>>,
          <<?a, 0xFDF0::utf8>>,
          <<?a, 0xFFFD::utf8>>
        ] do
      assert Sneeze.render([:p, %{name => "y"}]) == "<p #{name}=\"y\"></p>"
    end
  end

  test "non-string attribute values are stringified" do
    assert Sneeze.render([:img, %{width: 100, loading: :lazy}]) ==
             "<img loading=\"lazy\" width=\"100\" />"
  end

  test "true attribute values repeat the attribute name" do
    assert Sneeze.render([:input, %{disabled: true, type: "checkbox"}]) ==
             "<input disabled=\"disabled\" type=\"checkbox\" />"

    assert Sneeze.render([:p, %{"a&b" => true}]) == "<p a&b=\"a&amp;b\"></p>"
  end

  test "false and nil attribute values are omitted" do
    for value <- [false, nil] do
      assert Sneeze.render([:input, %{disabled: value, type: "checkbox"}]) ==
               "<input type=\"checkbox\" />"

      assert Sneeze.render([:p, %{hidden: value}, "hi"]) == "<p>hi</p>"
    end
  end

  test "a list with a single bare value is escaped" do
    assert Sneeze.render(["<b>"]) == "&lt;b&gt;"
    assert Sneeze.render([42]) == "42"
  end

  test "script and style tags with attributes" do
    assert Sneeze.render([:script, %{src: "a.js?x=1&y=2", defer: true, async: nil}, ""]) ==
             "<script defer=\"defer\" src=\"a.js?x=1&amp;y=2\"></script>"

    assert Sneeze.render([:style, %{media: "screen"}, [:__@raw_html, "a > b { color: red; }"]]) ==
             "<style media=\"screen\">a > b { color: red; }</style>"
  end

  test "attribute names are validated even when the value is omitted" do
    for value <- [false, nil] do
      assert_raise ArgumentError, ~r/invalid attribute name/, fn ->
        Sneeze.render([:p, %{"x onclick" => value}, "hi"])
      end
    end
  end

  test "list attribute values are joined with spaces and escaped" do
    assert Sneeze.render([:p, %{class: ["a&", :b, 3, nil, "c"]}]) ==
             "<p class=\"a&amp; b 3  c\"></p>"

    assert Sneeze.render([:p, %{class: []}]) == "<p class=\"\"></p>"
  end

  test "map attribute values are rendered as sorted styles and escaped" do
    data = [:p, %{style: %{"z-index" => 2, color: :red, content: "\"x\"", margin: nil}}]

    assert Sneeze.render(data) ==
             "<p style=\"color:red;content:&quot;x&quot;;margin:;z-index:2;\"></p>"

    assert Sneeze.render([:p, %{style: %{}}]) == "<p style=\"\"></p>"
    assert Sneeze.render([:p, %{style: %{"a" => 1, b: 2}}]) == "<p style=\"a:1;b:2;\"></p>"
  end

  test "charlist attribute values are lists of integers" do
    assert Sneeze.render([:p, %{title: ~c"hi"}]) == "<p title=\"104 105\"></p>"
  end

  test "struct attribute values are stringified, not rendered as styles" do
    assert Sneeze.render([:a, %{href: URI.parse("https://x.test/?a=1&b=2")}]) ==
             "<a href=\"https://x.test/?a=1&amp;b=2\"></a>"
  end

  test "tag shorthand for id and classes" do
    assert Sneeze.render([:"div#main", "x"]) == "<div id=\"main\">x</div>"
    assert Sneeze.render([:"div.a.b", "x"]) == "<div class=\"a b\">x</div>"
    assert Sneeze.render([:"div#main.a.b"]) == "<div class=\"a b\" id=\"main\"></div>"
    assert Sneeze.render([:"br.clear"]) == "<br class=\"clear\" />"
    assert Sneeze.render([:"input#q", %{type: "text"}]) == "<input id=\"q\" type=\"text\" />"
    assert Sneeze.render([:"p.a", %{}, "x"]) == "<p class=\"a\">x</p>"
    assert Sneeze.render(["span#s", %{}, "x"]) == "<span id=\"s\">x</span>"
  end

  test "tag shorthand merges with the attribute map" do
    assert Sneeze.render([:"p#short", %{id: "map"}]) == "<p id=\"map\"></p>"
    assert Sneeze.render([:"p#short", %{id: nil}]) == "<p id=\"short\"></p>"
    assert Sneeze.render([:"p.a", %{class: "b"}]) == "<p class=\"a b\"></p>"
    assert Sneeze.render([:"p.a", %{class: ["b", nil, :c]}]) == "<p class=\"a b c\"></p>"
    assert Sneeze.render([:"p.a", %{class: nil}]) == "<p class=\"a\"></p>"
    assert Sneeze.render([:"p.a", %{class: false}]) == "<p class=\"a\"></p>"

    assert Sneeze.render([:"p#s.a", %{"id" => "m", "class" => "b"}]) ==
             "<p class=\"a b\" id=\"m\"></p>"
  end

  test "tag shorthand values are escaped" do
    assert Sneeze.render([:"p#a&b"]) == "<p id=\"a&amp;b\"></p>"
    assert Sneeze.render([:"p#a#b"]) == "<p id=\"a#b\"></p>"
  end

  test "invalid tag names raise" do
    for tag <- [
          :"p onclick=alert(1)",
          :"p>",
          :"p/",
          :"p\"",
          :"p\tq",
          :"1p",
          :"-p",
          :"#main",
          :".a",
          :""
        ] do
      assert_raise ArgumentError, ~r/invalid tag name/, fn -> Sneeze.render([tag, "x"]) end
      assert_raise ArgumentError, ~r/invalid tag name/, fn -> Sneeze.render([tag]) end
      assert_raise ArgumentError, ~r/invalid tag name/, fn -> Sneeze.render([tag, %{}]) end
      assert_raise ArgumentError, ~r/invalid tag name/, fn -> Sneeze.render([tag, %{}, "x"]) end
    end

    # string and other non-atom tags are only recognised when followed by an
    # attribute map
    for tag <- ["", "p onclick=alert(1)", 1, {:p}] do
      assert_raise ArgumentError, ~r/invalid tag name/, fn -> Sneeze.render([tag, %{}, "x"]) end
    end
  end

  test "tag shorthand with classes before the id raises" do
    assert_raise ArgumentError, ~r/the id must come before classes/, fn ->
      Sneeze.render([:"div.a#b"])
    end
  end

  test "unusual but valid tag names are allowed" do
    for tag <- [:"my-element", :"svg:rect", :foreignObject, :"x-ünï", :H1] do
      assert Sneeze.render([tag, "x"]) == "<#{tag}>x</#{tag}>"
    end
  end

  test "enumerable children are rendered like lists" do
    assert Sneeze.render([:ul, Stream.map(1..2, &[:li, &1])]) == "<ul><li>1</li><li>2</li></ul>"
    assert Sneeze.render([:p, 1..3]) == "<p>123</p>"
    assert Sneeze.render([:p, %{}, "a", 1..2]) == "<p>a12</p>"

    stream = Stream.unfold(1, fn n -> if n <= 2, do: {[:i, n], n + 1} end)
    assert Sneeze.render([:p, stream]) == "<p><i>1</i><i>2</i></p>"

    assert Sneeze.render(Stream.map(["<", ">"], & &1)) == "&lt;&gt;"
  end

  test "enumerable nodes within sibling lists" do
    assert Sneeze.render([Stream.map(1..2, &[:li, &1]), [:p, "tail"]]) ==
             "<li>1</li><li>2</li><p>tail</p>"

    assert Sneeze.render([1..2, [:p, "tail"]]) == "12<p>tail</p>"
    assert Sneeze.render([[:p, "a"], 1..2, [:p, "b"]]) == "<p>a</p>12<p>b</p>"
    assert Sneeze.render([Stream.map(["<", ">"], & &1), [:p, "x"]]) == "&lt;&gt;<p>x</p>"
    assert Sneeze.render([Stream.map([], & &1), [:p, "x"]]) == "<p>x</p>"

    assert Sneeze.render([URI.parse("https://x.test/?a=1&b=2"), [:p, "x"]]) ==
             "https://x.test/?a=1&amp;b=2<p>x</p>"
  end

  test "non-enumerable struct children are stringified" do
    assert Sneeze.render([:p, URI.parse("https://x.test/?a=1&b=2")]) ==
             "<p>https://x.test/?a=1&amp;b=2</p>"
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
    assert Internal.attributes_to_iolist(%{id: "bar", class: "foo"}) ==
             [[" ", "class", "=\"", "foo", "\""], [" ", "id", "=\"", "bar", "\""]]
  end

  test "stable order of attributes, regardless of map key order" do
    assert Internal.attributes_to_iolist(%{c: "3", b: "2", a: "1"}) == [
             [" ", "a", "=\"", "1", "\""],
             [" ", "b", "=\"", "2", "\""],
             [" ", "c", "=\"", "3", "\""]
           ]
  end

  test "empty attributes" do
    assert Internal.attributes_to_iolist(%{}) == []
  end

  test "escape leaves strings without special characters unchanged" do
    assert Internal.escape("") == ""
    assert Internal.escape("plain text 🐜") == "plain text 🐜"
  end

  test "escape encodes each special character" do
    assert Internal.escape("a\"b'c&d<e>f") == "a&quot;b&#39;c&amp;d&lt;e&gt;f"
  end

  test "escape encodes each special character on its own" do
    assert Internal.escape("a\"b") == "a&quot;b"
    assert Internal.escape("a'b") == "a&#39;b"
    assert Internal.escape("a&b") == "a&amp;b"
    assert Internal.escape("a<b") == "a&lt;b"
    assert Internal.escape("a>b") == "a&gt;b"
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
