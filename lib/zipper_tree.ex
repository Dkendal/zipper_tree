defmodule ZipperTree do
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

  defmodule Node do
    @moduledoc """
    Represents a breadcrumb, or previous location in the tree of the cursor.
    left: all previous siblings of the current node.
    up: the previous path.
    right: all siblings that come after the current tree node/leaf.
    """
    defstruct left: [], up: Top, right: []
  end

  defmodule Loc do
    @moduledoc """
    Represents a cursor, or focused location in the tree.
    loc: the currently focused subtree.
    path: the current path back up the tree, read: ZipperTree.Node
    """
    defstruct loc: [], path: Top
  end

  def down(l) when is_list l do
    down %Loc{ loc: l }
  end

  @doc """
  descend into the the current subtree.
  """
  def down %Loc{loc: t, path: p} do
    case t do
      [h|trees] ->
        %Loc{loc: h, path: %Node{ up: p, right: trees }}

      _ ->
        {:error, "at leaf"}
    end
  end

  @doc """
  move the cursor to the previous subtree
  """
  def up %Loc{loc: t, path: p} do
    case p do
      Top ->
        {:error, "at top"}

      %Node{left: left, up: up, right: right} ->
        %Loc{loc: Enum.reverse(left) ++ [t | right], path: up}
    end
  end

  @doc """
  Move to the previous sibling of the current subtree
  """
  def left %Loc{loc: t, path: p} do
    case p do
      Top ->
        {:error, "left of top"}

      %Node{left: [], up: _, right: _} ->
        {:error, "left of first"}

      %Node{left: [l|left], up: up, right: right} ->
        %Loc{loc: l, path: %Node{left: left, up: up, right: [t|right]}}
    end
  end

  @doc """
  Move to the node after the current location.
  """
  def right %Loc{loc: t, path: p} do
    case p do
      Top ->
        {:error, "right of top"}

      %Node{left: left, up: up, right: [r|right]} ->
        %Loc{loc: r, path: %Node{left: [t|left], up: up, right: right}}

      _ ->
        {:error, "right of last"}
    end
  end

  @doc """
  Move to the nth most child of the current subtree.

  ## Examples
      iex> [1,2,[3,4]] |> ZipperTree.nth 3
      %ZipperTree.Loc{loc: [3, 4],
       path: %ZipperTree.Node{left: [2, 1],
        right: [], up: Top}}
  """
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

  @doc """
  Recursively move to the topmost node in linear time.
  """
  def top l do
    case l do
      %Loc{loc: _, path: Top} ->
        l

      _ ->
        top up l
    end
  end

  @doc """
  Change the value of the current node to t.
  """
  def change(%Loc{loc: _, path: p}, t), do: %Loc{loc: t, path: p}

  @doc """
  Insert r after the current node.
  """
  def insert_right %Loc{loc: t, path: p}, r do
    case p do
      Top ->
        {:error, "insert of top"}

      %Node{right: right} ->
        %Loc{loc: t, path: %Node{p | right: [r|right]}}
    end
  end

  @doc """
  Insert l before the current node.
  """
  def insert_left %Loc{loc: t, path: p}, l do
    case p do
      Top ->
        {:error, "insert of top"}

      %Node{left: left} ->
        %Loc{loc: t, path: %Node{p | left: [l|left]}}
    end
  end

  @doc """
  Insert t1 into the current subtree.
  """
  def insert_down %Loc{loc: t, path: p}, t1 do
    case t do
      _ when is_list t ->
        %Loc{loc: t1, path: %Node{up: p, right: t}}

      _ ->
        {:error, "cannot insert below leaf"}
    end
  end
end
