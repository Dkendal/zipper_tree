defmodule ZipperTreeTest do
  use ExUnit.Case, async: true
  import ZipperTree
  alias ZipperTree.Loc, as: Loc
  alias ZipperTree.Node, as: Node

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
    assert %Loc{loc: "1"} = down meta.tree
    assert {:error, "at leaf"} == down down meta.tree
  end

  test "up", meta do
    assert %Loc{loc: meta.tree, path: Top} == up down meta.tree
    assert {:error, "at top"} == up up down meta.tree
  end

  test "right", meta do
    assert %Loc{loc: "+"} = right down meta.tree
  end

  test "left", meta do
    assert %Loc{loc: "1"} = left right down meta.tree
  end

  test "nth" do
    tree = [
      1,
      2,
      3
    ]
    assert %Loc{loc: 3} = nth(tree, 3)
  end

  test "top", meta do
    tree = meta.tree
    assert %Loc{loc: ^tree, path: Top} = tree |> nth(3) |> nth(3) |> top
  end

  test "change" do
    tree = [1,2,[3, 4]]
    assert %Loc{loc: [1,2,[5, 4]]} = tree |> nth(3) |> down |> change(5) |> top
  end

  test "insert_right" do
    assert %Loc{loc: [1,2,3]} = [1,3] |> down |> insert_right(2) |> top

    assert {:error, "insert of top"} = [2,3] |> down |> top |> insert_right(1)
  end

  test "insert_left" do
    assert %Loc{loc: [1,2,3]} = [2,3] |> down |> insert_left(1) |> top
    assert {:error, "insert of top"} = [2,3] |> down |> top |> insert_left(1)
  end

  test "insert_down" do
    assert %Loc{loc: [1,2,[3,4,5]]} = [1,2,[4,5]] |> nth(3) |> insert_down(3) |> top
    assert {:error, "cannot insert below leaf"} = [1,2] |> down |> insert_down 1
  end
end
