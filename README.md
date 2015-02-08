ZipperTree
==========

An implementation of Gérard Huet's data structure originally published in
(Functional Pearl: The Zipper)[https://www.st.cs.uni-saarland.de/edu/seminare/2005/advanced-fp/docs/huet-zipper.pdf]

## WTF is a Zipper
A zipper is a novel method for encoding a focus, or position state of a collection
in purely functional languages. The zipper is an analogy for the process of moving
up and down the structure and how it can be thought of as opening and closing a zipper.
For a better description of the data structure I recommend you read the paper linked
above, although usage does not necessarily require you understand it's implementation.

## Usage
The implementation provided works for trees of variadic arity, simply define a
tree of type `@type tree :: record(:item, value: Type) | [tree]`
``` elixir
  tree = [
    item(value: "1"),
    item(value: "+"),
    [
      item(value: "2"),
      item(value: "*"),
      [
        item(value: "3"),
        item(value: "-"),
        item(value: "4"),
      ]
    ]
  ]
```

Tree traversal is done using the following:
```
down(loc()) :: loc()
down(tree()) :: loc()
left(loc()) :: loc()
right(loc()) :: loc()
up(loc()) :: loc()
```

To access the value of a leaf use `value(loc()) :: Type`, trying to access the
value of a non-leaf node will return `{:error, _}`. Likewise, invalid move
operations (up from the root, down from a leaf, etc.) will return `{:error, _}`
as per standard convention.
