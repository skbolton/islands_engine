defmodule RulesTest do
  use ExUnit.Case, async: true

  alias IslandsEngine.Rules

  describe "Rules.new/0" do
    test "returns a rules struct in corrct initial state" do
      %Rules{
        state: :initialized,
        player1: :islands_not_set,
        player2: :islands_not_set
      } = Rules.new()
    end
  end

  describe "Rules.check/2" do
    setup do
      %{rules: Rules.new()}
    end

    # This state represets the second player being added to game
    test "can move from :initialized state to :players_set", %{rules: rules} do
      assert {:ok, new_rules} = Rules.check(rules, :add_player)
      assert new_rules.state == :players_set
    end

    # We don't transition till a players state till we hear a :set_islands action
    test "does not change state while player is positioning islands", %{rules: rules} do
      # transition to state of having both players
      {:ok, rules} = Rules.check(rules, :add_player)
      assert {:ok, rules} = Rules.check(rules, {:position_islands, :player1})
      assert rules.state == :players_set
      assert rules.player1 == :islands_not_set
      # now test other player positioning islands
      assert {:ok, rules} = Rules.check(rules, {:position_islands, :player2})
      assert rules.state == :players_set
      assert rules.player2 == :islands_not_set
    end

    test "a single player setting their islands in final position", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, :add_player)
      assert {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
      # we dont' transition state yet since only one player has positioned
      assert rules.state == :players_set
      assert rules.player2 == :islands_set
    end

    test "both players setting their islands in final position", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, :add_player)
      assert {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
      assert {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
      # This time we will transition since both players have set their islands
      assert rules.state == :player1_turn
      assert rules.player2 == :islands_set
      assert rules.player1 == :islands_set
    end

    test "player1 taking their turn and not winning during it", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, :add_player)
      {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
      {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
      {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})

      assert rules.state == :player2_turn
    end

    test "player2 taking their turn and not winning during it", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, :add_player)
      {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
      {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
      {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})
      {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player2})

      assert rules.state == :player1_turn
    end

    test "a player cannot go if it is not their turn", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, :add_player)
      {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
      {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
      # have player2 try to go on player 1s turn
      assert :error = Rules.check(rules, {:guess_coordinate, :player2})
      {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})
      # have player1 go on player 2s turn
      assert :error = Rules.check(rules, {:guess_coordinate, :player1})
    end

    test "checking for win on player1s turn", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, :add_player)
      {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
      {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
      {:ok, rules} = Rules.check(rules, {:win_check, :win})

      assert rules.state == :game_over
    end

    test "checking for win on player2s turn", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, :add_player)
      {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
      {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
      # make it player 2s turn
      {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})
      {:ok, rules} = Rules.check(rules, {:win_check, :win})

      assert rules.state == :game_over
    end
  end
end
