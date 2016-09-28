defmodule SneezeTest do
  use ExUnit.Case
  doctest Sneeze

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "empty" do
    assert Sneeze.render([]) == ""
  end

  # test "really simple render" do
  #   assert Sneeze.render([:p, %{class: "greeting" }"hello"]) == "<p class=\"greeting\">hello</p>"
  # end
end

defmodule SneezeInternalsTest do
  use ExUnit.Case
  doctest Sneeze.Internals

  test "create attribute string from map" do
    attribs = %{class: "foo", id: "bar"}
    assert Sneeze.Internals.attributes_to_string(attribs) == "class=\"foo\" id=\"bar\""
  end
end
