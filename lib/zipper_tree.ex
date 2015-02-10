defmodule ZipperTree do
  require Record

  @type tree :: Type | [tree]

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
      [h|trees] ->
        loc location: h, path: path(up: p, right: trees)
      _ ->
        {:error, "at leaf"}
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

  def top l do
    case l do
      {:loc, _, Top} ->
        l
      _ ->
        top up l
    end
  end

  def change({:loc, _, p}, t), do: {:loc, t, p}

  def insert_right {:loc, t, p}, r do
    case p do
      Top ->
        {:error, "insert of top"}
      {:path, left, up, right} ->
        {:loc, t, {:path, left, up, [r|right]}}
    end
  end

  def insert_left {:loc, t, p}, l do
    case p do
      Top ->
        {:error, "insert of top"}

      {:path, left, up, right} ->
        {:loc, t, {:path, [l|left], up, right}}
    end
  end

  def insert_down {:loc, t, p}, t1 do
    case t do
      _ when is_list t ->
        {:loc, t1, path(up: p, right: t)}
      _ ->
        {:error, "cannot insert below leaf"}
    end
  end

  @spec value(loc) :: Type
  def value({:loc, val, _}), do: val
end
