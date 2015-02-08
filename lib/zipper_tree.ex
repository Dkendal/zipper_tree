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

      {:path, [], up, right} ->
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

  @spec value(loc) :: Type
  def value {:loc, {:item, val}, p} do
    val
  end

end
