defmodule GuessesTest do
  use ExUnit.Case, async: true
  alias IslandsEngine.{Guesses, Coordinate}

  describe "Guesses.new/0" do
    test "creates a guesses struct with an empty :hits and :misses set" do
      assert %Guesses{hits: hits, misses: misses} = Guesses.new()

      assert MapSet.size(hits) == 0
      assert MapSet.size(hits) == 0
    end
  end

  describe "Guesses.add/3" do
    setup do
      %{guesses: Guesses.new()}
    end

    test "adds coordinate to :hit collection on hit", %{guesses: guesses} do
      {:ok, coordinate_hit} = Coordinate.new(5, 5)
      new_guesses = Guesses.add(guesses, :hit, coordinate_hit)

      assert MapSet.member?(guesses.hits, coordinate_hit) == false
      assert MapSet.member?(new_guesses.hits, coordinate_hit) == true
    end

    test "adds coordinate to :miss collection on miss", %{guesses: guesses} do
      {:ok, coordinate_miss} = Coordinate.new(3, 6)
      new_guesses = Guesses.add(guesses, :miss, coordinate_miss)

      assert MapSet.member?(guesses.misses, coordinate_miss) == false
      assert MapSet.member?(new_guesses.misses, coordinate_miss) == true
    end
  end
end
