defmodule IslandTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.Island
  alias IslandsEngine.Coordinate

  describe "Island.new/2" do
    test "creating a :square island should have the correct starting coordinates" do
      {:ok, upper_left_coordinate} = Coordinate.new(1, 1)
      {:ok, upper_right_coordinate} = Coordinate.new(1, 2)
      {:ok, lower_left_coordinate} = Coordinate.new(2, 1)
      {:ok, lower_right_coordinate} = Coordinate.new(2, 2)

      assert {:ok, %Island{} = island} = Island.new(:square, upper_left_coordinate)

      expected_coordinates =
        MapSet.new([
          upper_left_coordinate,
          upper_right_coordinate,
          lower_left_coordinate,
          lower_right_coordinate
        ])

      assert MapSet.equal?(island.coordinates, expected_coordinates)
      assert MapSet.size(island.hit_coordinates) == 0
    end

    test "creating a :sqauare island that is out of bounds should error" do
      {:ok, upper_left_coordinate} = Coordinate.new(10, 10)

      assert {:error, :invalid_coordinate} = Island.new(:square, upper_left_coordinate)
    end

    test "creating an :atoll island should have correct starting coordinates" do
      {:ok, top_left_coordinate} = Coordinate.new(1, 1)
      {:ok, top_right_coordinate} = Coordinate.new(1, 2)
      {:ok, middle_coordinate} = Coordinate.new(2, 2)
      {:ok, lower_left_coordinate} = Coordinate.new(3, 1)
      {:ok, lower_right_coordinate} = Coordinate.new(3, 2)

      assert {:ok, %Island{} = island} = Island.new(:atoll, top_left_coordinate)

      expected_coordinates =
        MapSet.new([
          top_left_coordinate,
          top_right_coordinate,
          middle_coordinate,
          lower_left_coordinate,
          lower_right_coordinate
        ])

      assert MapSet.equal?(island.coordinates, expected_coordinates)
      assert MapSet.size(island.hit_coordinates) == 0
    end

    test "creating an :atoll island that is out of bounds should error" do
      {:ok, upper_left_coordinate} = Coordinate.new(1, 10)

      assert {:error, :invalid_coordinate} = Island.new(:square, upper_left_coordinate)
    end

    test "creating an :dot island should have correct starting coordinates" do
      {:ok, top_left_coordinate} = Coordinate.new(1, 1)

      assert {:ok, %Island{} = island} = Island.new(:dot, top_left_coordinate)

      expected_coordinates = MapSet.new([top_left_coordinate])

      assert MapSet.equal?(island.coordinates, expected_coordinates)
      assert MapSet.size(island.hit_coordinates) == 0
    end

    # Its not possible to write an out of bounds test for dot since it
    # is only one coordinate and trying to make it out of bounds fails

    test "creating an :l_shape island should have correct starting coordinates" do
      {:ok, top_left_coordinate} = Coordinate.new(1, 1)
      {:ok, middle_coordinate} = Coordinate.new(2, 1)
      {:ok, lower_left_coordinate} = Coordinate.new(3, 1)
      {:ok, lower_right_coordinate} = Coordinate.new(3, 2)

      assert {:ok, %Island{} = island} = Island.new(:l_shape, top_left_coordinate)

      expected_coordinates =
        MapSet.new([
          top_left_coordinate,
          middle_coordinate,
          lower_left_coordinate,
          lower_right_coordinate
        ])

      assert MapSet.equal?(island.coordinates, expected_coordinates)
      assert MapSet.size(island.hit_coordinates) == 0
    end

    test "creating an :l_shape island that is out of bounds should error" do
      {:ok, upper_left_coordinate} = Coordinate.new(9, 3)

      assert {:error, :invalid_coordinate} = Island.new(:l_shape, upper_left_coordinate)
    end

    test "creating an :s_shape island should have correct starting coordinates" do
      # the upperleft ends up being not in the islands coordinates with the s shape
      {:ok, upper_left_coordinate} = Coordinate.new(3, 3)
      {:ok, top_left_coordinate} = Coordinate.new(3, 4)
      {:ok, top_right_coordinate} = Coordinate.new(3, 5)
      {:ok, lower_left_coordinate} = Coordinate.new(4, 3)
      {:ok, lower_right_coordinate} = Coordinate.new(4, 4)

      assert {:ok, %Island{} = island} = Island.new(:s_shape, upper_left_coordinate)

      expected_coordinates =
        MapSet.new([
          top_left_coordinate,
          top_right_coordinate,
          lower_left_coordinate,
          lower_right_coordinate
        ])

      assert MapSet.equal?(island.coordinates, expected_coordinates)
      assert MapSet.size(island.hit_coordinates) == 0
    end

    test "creating an :s_shape island that is out of bounds should error" do
      {:ok, upper_left_coordinate} = Coordinate.new(9, 10)

      assert {:error, :invalid_coordinate} = Island.new(:s_shape, upper_left_coordinate)
    end
  end

  describe "Island.overlaps?/2" do
    test "returns true if the islands overlap on any coordinate" do
      {:ok, coordinate} = Coordinate.new(5, 5)
      {:ok, island_1} = Island.new(:square, coordinate)
      {:ok, island_2} = Island.new(:s_shape, coordinate)

      assert Island.overlaps?(island_1, island_2) == true
    end

    test "returns false if the islands do not overlap on any coordinate" do
      {:ok, coordinate} = Coordinate.new(5, 5)
      {:ok, other_coordinate} = Coordinate.new(1, 1)
      {:ok, s_shape} = Island.new(:s_shape, coordinate)
      {:ok, l_shape} = Island.new(:l_shape, other_coordinate)

      assert Island.overlaps?(s_shape, l_shape) == false
    end
  end

  describe "Island.forested?/1" do
    test "returns true if all the coordinates on an island have been hit" do
      {:ok, upper_left} = Coordinate.new(1, 1)
      {:ok, upper_right} = Coordinate.new(1, 2)
      {:ok, lower_left} = Coordinate.new(2, 1)
      {:ok, lower_right} = Coordinate.new(2, 2)
      {:ok, island} = Island.new(:square, upper_left)

      # manually fill up island
      island = %{
        island
        | hit_coordinates: MapSet.new([upper_left, upper_right, lower_left, lower_right])
      }

      assert Island.forested?(island) == true
    end

    test "returns false if all the coordinates on an island have not been hit" do
      {:ok, upper_left} = Coordinate.new(8, 8)
      {:ok, island} = Island.new(:square, upper_left)

      assert Island.forested?(island) == false
    end
  end

  describe "Island.guess/2" do
    test "returns {:hit, island} when guessed coordinate is one of islands coordinates" do
      {:ok, upper_left} = Coordinate.new(5, 5)
      {:ok, island} = Island.new(:atoll, upper_left)
      {:ok, should_be_hit_coordinate} = Coordinate.new(5, 6)

      assert {:hit, new_island} = Island.guess(island, should_be_hit_coordinate)
      assert MapSet.member?(new_island.hit_coordinates, should_be_hit_coordinate)
    end

    test "returns :miss when guessed coordinate is not one of islands coordinates" do
      {:ok, upper_left} = Coordinate.new(7, 8)
      {:ok, island} = Island.new(:s_shape, upper_left)
      {:ok, should_be_a_miss_coordinate} = Coordinate.new(2, 2)

      assert :miss = Island.guess(island, should_be_a_miss_coordinate)
    end
  end

  describe "Island.types/0" do
    test "returns all valid types of islands" do
      # Putting types in a mapset so order doesn't matter
      types = MapSet.new(Island.types())
      expected = MapSet.new([:atoll, :square, :dot, :s_shape, :l_shape])

      assert MapSet.equal?(types, expected) == true
    end
  end
end
