defmodule BoardTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.{Coordinate, Island, Board}

  describe "Board.new/0" do
    test "creates a new board" do
      assert %{} = Board.new()
    end
  end

  describe "Board.position_island/3" do
    setup do
      %{board: Board.new()}
    end

    test "adds island to board as given it doesn't overlap a previous island", %{board: board} do
      {:ok, square_upper_left} = Coordinate.new(8, 8)
      {:ok, square} = Island.new(:square, square_upper_left)
      board = Board.position_island(board, :square, square)

      {:ok, dot_upper_left} = Coordinate.new(4, 4)
      {:ok, dot} = Island.new(:dot, dot_upper_left)
      board = Board.position_island(board, :dot, dot)

      assert Map.get(board, :square) == square
      assert Map.get(board, :dot) == dot
    end

    test "returns error if island overlaps a previously positioned island", %{board: board} do
      {:ok, square_upper_left} = Coordinate.new(8, 8)
      {:ok, square} = Island.new(:square, square_upper_left)
      board = Board.position_island(board, :square, square)

      {:ok, dot_upper_left} = Coordinate.new(9, 9)
      {:ok, dot} = Island.new(:dot, dot_upper_left)
      assert {:error, :overlapping_island} = Board.position_island(board, :dot, dot)
    end
  end

  describe "Board.all_islands_positioned?/1" do
    setup do
      %{board: Board.new()}
    end

    test "returns true if all island types have been positioned", %{board: board} do
      {:ok, dot_coordinate} = Coordinate.new(1, 1)
      {:ok, square_coordinate} = Coordinate.new(1, 3)
      {:ok, atoll_coordinate} = Coordinate.new(1, 6)
      {:ok, l_shape_coordinate} = Coordinate.new(3, 1)
      {:ok, s_shape_coordinate} = Coordinate.new(6, 6)
      {:ok, dot} = Island.new(:dot, dot_coordinate)
      {:ok, square} = Island.new(:square, square_coordinate)
      {:ok, atoll} = Island.new(:atoll, atoll_coordinate)
      {:ok, l_shape} = Island.new(:l_shape, l_shape_coordinate)
      {:ok, s_shape} = Island.new(:s_shape, s_shape_coordinate)

      # Place all islands in board manually
      board =
        board
        |> Map.put(:dot, dot)
        |> Map.put(:square, square)
        |> Map.put(:atoll, atoll)
        |> Map.put(:l_shape, l_shape)
        |> Map.put(:s_shape, s_shape)

      assert Board.all_islands_positioned?(board) == true
    end
  end

  describe "Board.guess/2" do
    setup do
      {:ok, dot_coordinate} = Coordinate.new(1, 1)
      {:ok, square_coordinate} = Coordinate.new(1, 3)
      {:ok, atoll_coordinate} = Coordinate.new(1, 6)
      {:ok, l_shape_coordinate} = Coordinate.new(3, 1)
      {:ok, s_shape_coordinate} = Coordinate.new(6, 6)
      {:ok, dot} = Island.new(:dot, dot_coordinate)
      {:ok, square} = Island.new(:square, square_coordinate)
      {:ok, atoll} = Island.new(:atoll, atoll_coordinate)
      {:ok, l_shape} = Island.new(:l_shape, l_shape_coordinate)
      {:ok, s_shape} = Island.new(:s_shape, s_shape_coordinate)
      board = Board.new()

      board =
        board
        |> Board.position_island(:dot, dot)
        |> Board.position_island(:square, square)
        |> Board.position_island(:atoll, atoll)
        |> Board.position_island(:l_shape, l_shape)
        |> Board.position_island(:s_shape, s_shape)

      %{board: board, dot: dot, square: square, l_shape: l_shape, s_shape: s_shape, atoll: atoll}
    end

    test "guessing that results in a hit, forested island, and not a win", %{board: b} do
      # This is a coordinate in our dot island
      {:ok, guess_coordinate} = Coordinate.new(1, 1)
      assert {:hit, :dot, :no_win, _board} = Board.guess(b, guess_coordinate)
    end

    test "guessing that results in a hit, non forested island, and not a win", %{board: b} do
      # this is a coordinate in our l_shape
      {:ok, guess_coordinate} = Coordinate.new(4, 1)
      assert {:hit, :none, :no_win, _board} = Board.guess(b, guess_coordinate)
    end

    test "guessing that results in a hit, forested island, and a win", %{
      board: board,
      square: square,
      l_shape: l_shape,
      s_shape: s_shape,
      atoll: atoll
    } do
      # For all islands other than dot guess their coordinates
      board =
        [square, l_shape, s_shape, atoll]
        |> Enum.flat_map(fn island -> island.coordinates end)
        |> Enum.reduce(board, fn coordinate, board ->
          {_hit_or_miss, _forested?, _win_or_not, board} = Board.guess(board, coordinate)
          board
        end)

      # now guess the dot island coordinate which should cause game end
      {:ok, dot_coordinate} = Coordinate.new(1, 1)
      assert {:hit, :dot, :win, _board} = Board.guess(board, dot_coordinate)
    end
  end
end
