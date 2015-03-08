defmodule Zipper do
  require Record

  @moduledoc """
  Provides traversal and modification methods for variadic arity trees. All
  methods maintain an active 'cursor' or focus in the tree. The methods will
  also technically work for lists too - I guess, if you're into that sorta
  thing.

  All traversal and insertion methods happen in constant time with exception to
  up, which is porportional to how many nodes were junior to the current subtree.

  This is an implementation of Gérard Huet's tree with a zipper, essentially a
  direct conversion of the published oocaml code to elixir.
  """

  defmodule Path do
    @moduledoc """
    Represents a breadcrumb, or previous location in the tree of the cursor.
    left: all previous siblings of the current node.
    up: the previous path.
    right: all siblings that come after the current tree node/leaf.
    """
    defstruct left: [], up: Top, right: [], parent: nil
  end

  Record.defrecord :loc, current: nil, context: Top

  @type path :: %Path{ left: [tree], up: path, right: [tree] } | Top
  @type location :: { :loc, tree, path }
  @type leaf :: any
  @type tree :: [ leaf | [tree | leaf] ]

  @doc """
  Used convert a tree type into a location type.
  Required before any Zipper methods can be called on it.
  """
  @spec open( tree ) :: location
  def open( [ _ | c ] = t ) when is_list c do
    loc( current: t, context: Top  )
  end

  @doc """
  Returns the value of the current node or leaf.
  """
  @spec value( location ) :: any
  def value( { :loc, [ v | _ ], _ } ), do: v

  @doc ~S"""
  Descend down into the pre order child of this node.

  ## Eg.
       [1]                1
       / \   - down ->   / \ 
      2   3            [2]  3
  """
  def down { :loc, t, p } do
    case t do
      [ val, c | children ] ->
        { :loc, c, %Path{ up: p, right: children, parent: val } }

      _ ->
        {:error, "at leaf"}
    end
  end

  @doc ~S"""
  Move up to the parent of the current node.
  """
  def up { :loc, t, p } do
    case p do
      Top ->
        {:error, "at top"}

      %Path{left: left, up: up, right: right, parent: parent} ->
        { :loc, [ parent | Enum.reverse(left) ++ [t | right] ], up }
    end
  end

  @doc ~S"""
  Move to the node to the left of the current node.
  """
  def left { :loc, t, p } do
    case p do
      Top ->
        {:error, "left of top"}

      %Path{left: [], up: _, right: _} ->
        {:error, "left of first"}

      %Path{left: [l|left], right: right} ->
        { :loc, l, %Path{ p | left: left, right: [t|right]} }
    end
  end

  @doc ~S"""
  Move to the node to the right of the current node.
  """
  def right { :loc, t, p } do
    case p do
      Top ->
        {:error, "right of top"}

      %Path{left: left, right: [r|right]} ->
        { :loc, r, %Path{ p | left: [t|left], right: right} }

      _ ->
        {:error, "right of last"}
    end
  end

  def nth loc, n do
    case n do
      1 ->
        down loc

      _ when n > 0  ->
        right nth(loc, n-1)

      _ ->
        {:error, "nth expects a postive integer"}
    end
  end

  @doc ~S"""
  Move to the root of the tree.
  """
  def top l do
    case l do
      { :loc, _, Top } -> l
      _ -> top up l
    end
  end

  def change( { :loc, _, p }, t ), do: { :loc, t, p }
  def change_value( { :loc, [ _ | c ], p }, t ), do: { :loc, [ t | c ], p }

  @doc ~S"""
  Insert a new leaf to the right of the current node.
  """
  def insert_right { :loc, t, p }, r do
    case p do
      Top ->
        {:error, "insert of top"}

      %Path{ right: right } ->
        { :loc, t, %Path{ p | right: [r|right] } }
    end
  end

  @doc ~S"""
  Insert a new leaf to the left of the current node.
  """
  def insert_left { :loc, t, p }, l do
    case p do
      Top ->
        {:error, "insert of top"}

      %Path{left: left} ->
        { :loc, t, %Path{p | left: [l|left]} }
    end
  end

  @doc ~S"""
  Insert a new leaf below the current node. If the current node is a leaf it
  will be converted to a node.
  """
  def insert_down { :loc, tree, _path } = l, d do
    [ val | children ] = List.wrap tree
    loc l, current: [ val, d | children ]
  end

  # Transformations
  @spec transform( tree, ( tree -> any ) ) :: any
  defp transform( tree, fun ) when is_list tree do
    fun.(tree)
  end

  defp transform( leaf, fun ) do
    [ r ] = fun.([ leaf ])
    r
  end

  @spec prewalk( location, ( tree -> any ) ) :: location
  @doc """
  preform a pre order walk, applying the function `fun` to each subtree.
  fun :: (tree -> any)
  """
  def prewalk( { :loc, tree, _path } = l, fun ) do
    loc l, current: ( prewalk tree, fun )
  end

  def prewalk(tree, fun) do
    [ value | children ] = List.wrap fun.( ( List.wrap tree ) )
    case children do
      [] -> value
      _ -> [ value | ( Enum.map children, &(prewalk &1, fun) ) ]
    end
  end

  @spec postwalk( location, ( tree -> any ) ) :: location
  @doc """
  preform a post order walk, applying the function `fun` to each subtree.
  fun :: (tree -> any)
  """
  def postwalk( { :loc, tree, _path } = l, fun ) do
    loc l, current: ( postwalk tree, fun )
  end

  def postwalk([ value | children ], fun) do
    [ value | ( Enum.map children, &(postwalk &1, fun) ) ]
    |> transform fun
  end

  def postwalk(leaf, fun) do
    transform leaf, fun
  end
end
