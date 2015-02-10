defmodule ZipperTree do
  defmodule Node do
    defstruct left: [], up: Top, right: []
  end

  defmodule Loc do
    defstruct loc: nil, path: Top
  end

  def down(l) when is_list l do
    down %Loc{ loc: l }
  end

  def down %Loc{loc: t, path: p} do
    case t do
      [h|trees] ->
        %Loc{loc: h, path: %Node{ up: p, right: trees }}

      _ ->
        {:error, "at leaf"}
    end
  end

  def up %Loc{loc: t, path: p} do
    case p do
      Top ->
        {:error, "at top"}

      %Node{left: left, up: up, right: right} ->
        %Loc{loc: Enum.reverse(left) ++ [t | right], path: up}
    end
  end

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
      %Loc{loc: _, path: Top} ->
        l

      _ ->
        top up l
    end
  end

  def change(%Loc{loc: _, path: p}, t), do: %Loc{loc: t, path: p}

  def insert_right %Loc{loc: t, path: p}, r do
    case p do
      Top ->
        {:error, "insert of top"}

      %Node{right: right} ->
        %Loc{loc: t, path: %Node{p | right: [r|right]}}
    end
  end

  def insert_left %Loc{loc: t, path: p}, l do
    case p do
      Top ->
        {:error, "insert of top"}

      %Node{left: left} ->
        %Loc{loc: t, path: %Node{p | left: [l|left]}}
    end
  end

  def insert_down %Loc{loc: t, path: p}, t1 do
    case t do
      _ when is_list t ->
        %Loc{loc: t1, path: %Node{up: p, right: t}}

      _ ->
        {:error, "cannot insert below leaf"}
    end
  end
end
