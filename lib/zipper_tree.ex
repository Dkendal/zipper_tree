defmodule ZipperTree do
  require Record

  Record.defrecord :item, value: nil
  @type tree :: record(:item, value: Type) | [tree]

  Record.defrecord :path, left: [], up: Top, right: []
  @type path :: Top | record(:path, left: [tree], up: path, right: [tree])

  Record.defrecord :loc, location: nil, path: Top
  @type loc :: record :loc, location: tree, path: path

  @spec down(tree) :: loc
  def down(l) when is_list l do
    down loc(location: l)
  end

  @spec down(loc) :: loc
  def down {:loc, t, p} do
    case t do
      {:item, _} ->
        {:error, "at leaf"}
      [h|trees] ->
        loc location: h, path: path(up: p, right: trees)
    end
  end

  @spec up(loc) :: loc
  def up {:loc, t, p} do
    case p do
      Top ->
        {:error, "at top"}
      {:path, left, up, right} ->
        loc location: Enum.reverse(left) ++ [t | right], path: up
    end
  end

  @spec left(loc) :: loc
  def left {:loc, t, p} do
    case p do
      Top ->
        {:error, "left of top"}

      {:path, [], _, _} ->
        {:error, "left of first"}

      {:path, [l|left], up, right} ->
        loc(location: l, path: path(left: left, up: up, right: [t|right]))
    end
  end

  @spec right(loc) :: loc
  def right {:loc, t, p} do
    case p do
      Top ->
        {:error, "right of top"}
      {:path, left, up, [r|right]} ->
        loc(location: r, path: path(left: [t|left], up: up, right: right))
      _ ->
        {:error, "right of last"}
    end
  end
  # let nth loc = nthrec
  # where rec nthrec = function
  # 1 -> go_down(loc)
  # | n -> if n>0 then go_right(nthrec (n-1))
  # else failwith "nth expects a positive integer";;
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

  @spec value(loc) :: Type
  def value {:loc, {:item, val}, _} do
    val
  end

end
