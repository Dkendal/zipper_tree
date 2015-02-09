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

  test "top", meta do
    tree = meta.tree
    assert {:loc, ^tree, Top} = tree |> nth(3) |> nth(3) |> top
  end

  test "change" do
    tree = [1,2,[3, 4]]
    assert {:loc, [1,2,[5, 4]], _} = tree |> nth(3) |> down |> change(5) |> top
  end

  test "insert_right" do
    assert {_, [1,2,3], _} = [1,3] |> down |> insert_right(2) |> top

    assert {:error, "insert of top"} = [2,3] |> down |> top |> insert_right(1)
  end

  test "insert_left" do
    assert {_, [1,2,3], _} = [2,3] |> down |> insert_left(1) |> top
    assert {:error, "insert of top"} = [2,3] |> down |> top |> insert_left(1)
  end

  test "insert_down" do
    assert {_, [1,2,[3,4,5]], _} = [1,2,[4,5]] |> nth(3) |> insert_down(3) |> top
    assert {:error, "cannot insert below leaf"} = [1,2] |> down |> insert_down 1
  end
end
