defmodule CoordinateTest do
  use ExUnit.Case, async: true
  alias IslandsEngine.Coordinate

  describe "Coordinate.new/2" do
    test "can only create valid coordinates in range of 1..10" do
      assert {:ok, coordinate} = Coordinate.new(1, 1)

      assert {:error, :invalid_coordinate} = Coordinate.new(11, 1)
      assert {:error, :invalid_coordinate} = Coordinate.new(-1, 1)
    end
  end
end
