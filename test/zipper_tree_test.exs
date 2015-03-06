defmodule ZipperTreeTest do
  use ExUnit.Case, async: true
  import ZipperTree

  setup do
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


  @tag timeout: 10
  test "creates a tree from a list", meta do
    list = meta.tree
    assert tree(list) === { :loc, list, Top }
  end

  @tag timeout: 10
  @tag focus: true
  test "down", meta do
    assert { :loc, "1", _ } = down tree meta.tree
    assert {:error, "at leaf"} == down down tree meta.tree
  end

  @tag timeout: 10
  test "up", meta do
    assert { :loc, meta.tree, Top } == up down tree meta.tree
    assert {:error, "at top"} == up up down tree meta.tree
  end

  @tag timeout: 10
  test "right", meta do
    assert { :loc, "+", _ } = right down tree meta.tree
  end

  @tag timeout: 10
  test "left", meta do
    assert { :loc, "1", _ } = left right down tree meta.tree
  end

  @tag timeout: 10
  test "nth" do
    t = [ 1, 2, 3 ]
    assert { :loc, 3, _ } = t |> tree |> nth(3)
  end

  @tag timeout: 10
  test "top", meta do
    t = meta.tree
    assert { :loc, ^t, Top } = t |> tree |> nth(3) |> nth(3) |> top
  end

  @tag timeout: 10
  test "change" do
    t = [1,2,[3, 4]]
    assert { :loc, [1,2,[5, 4]], _ } = t |> tree |> nth(3) |> down |> change(5) |> top
  end

  @tag timeout: 10
  test "insert_right" do
    assert { :loc, [1,2,3], _ } = [1,3] |> tree |> down |> insert_right(2) |> top

    assert {:error, "insert of top"} = [2,3] |> tree |> down |> top |> insert_right(1)
  end

  @tag timeout: 10
  test "insert_left" do
    assert { :loc, [1,2,3], _ } = [2,3] |> tree |> down |> insert_left(1) |> top
    assert {:error, "insert of top"} = [2,3] |> tree |> down |> top |> insert_left(1)
  end

  @tag timeout: 10
  test "insert_down" do
    assert { :loc, [1,2,[3,4,5]], _ } = [1,2,[4,5]] |> tree |> nth(3) |> insert_down(3) |> top
    assert {:error, "cannot insert below leaf"} = [1,2] |> tree |> down |> insert_down 1
  end

end
