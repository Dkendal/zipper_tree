ZipperTree
==========

An implementation of Gérard Huet's data structure originally published in
[Functional Pearl: The Zipper](https://www.st.cs.uni-saarland.de/edu/seminare/2005/advanced-fp/docs/huet-zipper.pdf)

## WTF is a Zipper
A zipper is a novel method for encoding a focus, or position state of a collection
in purely functional languages. The zipper is an analogy for the process of moving
up and down the structure and how it can be thought of as opening and closing a zipper.
For a better description of the data structure I recommend you read the paper linked
above, although usage does not necessarily require you understand it's implementation.

## Usage
The implementation provided works for trees of variadic arity, simply define a
tree of type `@type tree :: Type | [tree]`

Tree traversal is done using the following:
```elixir
down(loc()) :: loc()
down(tree()) :: loc()
left(loc()) :: loc()
right(loc()) :: loc()
up(loc()) :: loc()
nth(loc(), Integer) :: loc()
```
To access the value of a leaf use `value(loc()) :: Type`, trying to access the
value of a non-leaf node will return `{:error, _}`. Likewise, invalid move
operations (up from the root, down from a leaf, etc.) will return `{:error, _}`
as per standard convention.
####e.g.
``` elixir
  iex()> tree = [
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
iex()> tree |> down |> value
"1"
iex()> tree |> down |> right |> right |> down |> value
"2"
iex()> tree |> nth 3 |> nth 3                                                 
{:loc, ["3", "-", "4"], {:path, ["*", "2"], {:path, ["+", "1"], Top, []}, []}}
```
