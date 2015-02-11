ZipperTree
==========
Provides traversal and modification methods for variadic arity tree's. All
methods maintain an active 'cursor' or focus in the tree. The methods will
also technically work for lists too - I guess, if you're into that sorta
thing.

All traversal and insertion methods happen in constant time with exception to
up, which is porportional to how many nodes were junior to the current subtree.

This is an implementation of Gérard Huet's tree with a zipper (originally
published in [Functional Pearl: The
Zipper](https://www.st.cs.uni-saarland.de/edu/seminare/2005/advanced-fp/docs/huet-zipper.pdf)),
essentially a direct conversion of the published oocaml code to elixir.

## WTF is a Zipper
A zipper is a novel method for encoding a focus, or position state of a collection
in purely functional languages. The zipper is an analogy for the process of moving
up and down the structure and how it can be thought of as opening and closing a zipper.
For a better description of the data structure I recommend you read the paper linked
above, although usage does not necessarily require you understand it's implementation.

## Usage
Just add `{:zipper_tree, "~> 0.1.0"}` to your dependencies.

The implementation provided works for trees of variadic arity, simply define a
tree using nested lists
```elixir
iex(3)> import ZipperTree

iex(4)> tree = [
  1,
  2,
  [
    3,
    4
  ]
]

[1, 2, [3, 4]]

iex(5)> tree |> nth(3)
%ZipperTree.Loc{loc: [3, 4],
 path: %ZipperTree.Node{left: [2, 1], right: [], up: Top}}

iex(6)> tree |> nth(3) |> right
{:error, "right of last"}

iex(7)> tree |> nth(3) |> down
%ZipperTree.Loc{loc: 3,
 path: %ZipperTree.Node{left: [], right: [4],
  up: %ZipperTree.Node{left: [2, 1], right: [], up: Top}}}

iex(8)> tree |> nth(3) |> down |> right
%ZipperTree.Loc{loc: 4,
 path: %ZipperTree.Node{left: [3], right: [],
  up: %ZipperTree.Node{left: [2, 1], right: [], up: Top}}}

iex(9)> tree |> nth(3) |> down |> right |> top
%ZipperTree.Loc{loc: [1, 2, [3, 4]], path: Top}

iex(10)> tree |> nth(3) |> down |> right |> change(:sup) |> top
%ZipperTree.Loc{loc: [1, 2, [3, :sup]], path: Top}

iex(11)> tree |> nth(3) |> down |> right |> insert_left(:over_here_now) |> top
%ZipperTree.Loc{loc: [1, 2, [3, :over_here_now, 4]], path: Top}
```

Then move around the tree using `down`, `left`, `right`, `up`, `nth`, `top` and
make modifications with `change`, `insert_down`, `insert_left`, `insert_right`.

For specific method examples check the tests.

## Road map
- [x] traversal
- [x] modification and insertion
- [ ] various search strategies
- [ ] ???
