defmodule ZipperTest do
  use ExUnit.Case, async: true
  alias Zipper, as: Z

  setup do
    #     1
    #    / \
    #   2   4
    #  /   / \
    # 3   5   7
    #    /
    #   6
    tree = { 1,
             [
               { 2, [ 3 ] },
               { 4,
                 [
                   { 5, [ 6 ] },
                   7 ] } ] }

    simple = { 1, [ { 2, [ 3 ] } ] }
    simple_tree = {:loc, {1, [{2, [3]}]}, Top}

    bxt = { &+/2,
            [ 1,
              { &-/2, [ 3, 2 ] } ] }

    #      1
    # 2 3 [4] 5 6
    wide_tree = {:loc, 4,
      %Zipper.Path{
        left: [3, 2],
        right: [5, 6],
        parent: 1,
        up: Top}}

    leaf = {:loc, 3,
      %Zipper.Path{left: [], parent: 2, right: [],
        up: %Zipper.Path{left: [], parent: 1, right: [], up: Top}}}

    { :ok,
      tree: tree,
      simple: simple,
      bxt: bxt,
      leaf: leaf,
      wide_tree: wide_tree,
      simple_tree: simple_tree }
  end

  test "location record" do
    require Zipper
    assert { :loc, nil, Top } === Z.loc()
  end

  test "initialize a new zipper", context do
    assert ( Z.open context.tree ) == { :loc, context.tree, Top }
  end

  test "accessing the value at a node", context do
    assert ( Z.value Z.open context.tree  ) == 1
  end

  test "descending a tree", context do
    assert { :loc, { 2, [ 3 ] }, _ } = ( Z.down context.simple_tree )
    assert { :error, "at leaf" } = ( Z.down context.leaf )
  end

  test "ascending a tree", context do
    t = context.simple
    assert { :loc, ^t, _ } = ( Z.up Z.up context.leaf )
    assert { :error, "at top" } = ( Z.up Z.open context.tree )
  end

  test "moving left", context do
    assert { :loc, 3, _ } = Z.left context.wide_tree
    assert { :error, "left of top" } == Z.left context.simple_tree
    assert { :error, "left of first" } == Z.left context.leaf
  end

  test "moving right", context do
    assert { :loc, 5, _ } = Z.right context.wide_tree
    assert { :error, "right of top" } == Z.right context.simple_tree
    assert { :error, "right of last" } == Z.right context.leaf
  end

  test "returning to the top", context do
    t = context.simple
    assert { :loc, ^t, _ } = ( Z.top context.leaf )
  end

  test "changing a value", context do
    assert { :loc, 9, _ } = ( Z.change_value context.leaf, 9 )
    assert { :loc, { 9, _ }, _ } =
      ( Z.change_value ( Z.down context.simple_tree ), 9 )
  end

  test "inserting a value to the right", context do
    assert { :loc, _, %Z.Path{ right: [ 9 | _ ] } } =
      ( Z.insert_right context.leaf, 9 )
  end

  test "inserting a value to the left", context do
    assert { :loc, _, %Z.Path{ left: [ 9 | _ ] } } =
      ( Z.insert_left context.leaf, 9 )
  end

  test "inserting a value below the current node", context do
    # at leaf
    assert { :loc, { 3, [ 9 ] }, _ } = ( Z.insert_down context.leaf, 9 )
    # at node
    assert { :loc, { 1, [ 9, { 2, [ 3 ] } ] }, _ } =
      ( Z.insert_down context.simple_tree, 9 )
  end

  test "prewalk transformation", context do
    tree = { :loc, { 2, [ { 4, [ 6 ] }, { 8, [ { 10, [ 12 ] }, 14 ] } ] }, Top }
    assert ^tree = Z.prewalk ( Z.open context.tree ), fn ( { x, c } ) ->
      { x * 2, c }
    end
  end

  test "postwalk transformation", context do
    assert { :loc, 2, Top } = Z.postwalk ( Z.open context.bxt ), fn ( { f, args } ) ->
      is_function(f) && apply(f, args) || { f, args }
    end
  end
end
