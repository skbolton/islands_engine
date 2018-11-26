defmodule GameTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.Game

  describe "Game.start_link/1" do
    test "starting a game under a given name returns a pid" do
      {:ok, game} = Game.start_link("Dwayne")
      assert is_pid(game)
    end
  end

  describe "Game.add_player/2" do
    setup do
      game = start_supervised!({Game, "Dwayne"})
      %{game: game}
    end

    test "returns :ok when adding second player to game", %{game: game} do
      assert :ok = Game.add_player(game, "Walter")
    end

    test "errors adding a second player after they have already been added", %{game: game} do
      Game.add_player(game, "Gerry")
      assert :error = Game.add_player(game, "Kevin")
    end
  end
end
