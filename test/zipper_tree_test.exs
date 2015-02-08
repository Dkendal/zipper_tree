defmodule ZipperTreeTest do
  use ExUnit.Case, async: true
  import ZipperTree

  setup do
    # 1 + 2 * ( 3 - 4 )
    tree = [
      "1",
      "+",
      [
        "2",
        "*",
        [
          "3",
          "-",
          "4",
        ]
      ]
    ]
    {:ok, tree: tree}
  end

  test "down", meta do
    assert "1" == value down meta.tree
    assert {:error, "at leaf"} == down down meta.tree
  end

  test "up", meta do
    assert loc(location: meta.tree, path: Top) == up down meta.tree
    assert {:error, "at top"} == up up down meta.tree
  end

  test "right", meta do
    assert "+" == value right down meta.tree
    assert "2" == value down right right down meta.tree
  end

  test "left", meta do
    assert "1" == value left right down meta.tree
  end

  test "nth" do
    tree = [
      1,
      2,
      3
    ]
    assert 3 == value nth(tree, 3)
  end

  test "change" do
    tree = [1,2,[3, 4]]
    assert {:loc, [1,2,[5, 4]], _} = tree |> nth(3) |> down |> change(5) |> up |> up
  end
end
