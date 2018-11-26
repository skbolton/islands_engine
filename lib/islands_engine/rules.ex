defmodule IslandsEngine.Rules do
  alias IslandsEngine.Rules

  defstruct state: :initialized, player1: :islands_not_set, player2: :islands_not_set

  def new do
    %Rules{}
  end

  def check(%Rules{state: :initialized} = rules, :add_player) do
    {:ok, %Rules{rules | state: :players_set}}
  end

  # They can only position if they didn't previously set their islands
  def check(%Rules{state: :players_set} = rules, {:position_islands, player}) do
    case Map.fetch!(rules, player) do
      :islands_not_set -> {:ok, rules}
      :islands_set -> :error
    end
  end

  def check(%Rules{state: :players_set} = rules, {:set_islands, player}) do
    rules = Map.put(rules, player, :islands_set)

    case both_players_islands_set?(rules) do
      true ->
        {:ok, %Rules{rules | state: :player1_turn}}

      false ->
        {:ok, rules}
    end
  end

  # Transition from player1s turn to player2
  def check(%Rules{state: :player1_turn} = rules, {:guess_coordinate, :player1}) do
    {:ok, %Rules{rules | state: :player2_turn}}
  end

  # Transition from player2s turn to player1
  def check(%Rules{state: :player2_turn} = rules, {:guess_coordinate, :player2}) do
    {:ok, %Rules{rules | state: :player1_turn}}
  end

  # update state on win condition for player1
  def check(%Rules{state: :player1_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win -> {:ok, %Rules{rules | state: :game_over}}
    end
  end

  # update state for win condition for player2
  def check(%Rules{state: :player2_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win -> {:ok, %Rules{rules | state: :game_over}}
    end
  end

  def check(_state, _action), do: :error

  defp both_players_islands_set?(rules) do
    rules.player1 == :islands_set && rules.player2 == :islands_set
  end
end
