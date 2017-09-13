defmodule GameTest do
  use ExUnit.Case

  alias Hangman.Game

  test "new_game returns structure" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
    assert Regex.match?(~r/[a-z]*/, Enum.join(game.letters))
  end

  test "state isn't changed for :won or :lost game" do
    for state <- [:won, :lost] do
      game = Game.new_game() |> Map.put(:game_state, state)
      assert {^game, _tally} = Game.make_move(game, "x")
    end
  end

  test "first occurence of letter is not already used" do
    game = Game.new_game()
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state != :already_guessed
  end

  test "second occurence of letter is not already used" do
    game = Game.new_game()
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state != :already_guessed
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state == :already_guessed
  end

  test "a good guess is recognized" do
    game = Game.new_game("wibble")
    { game, _tally } = Game.make_move(game, "w")
    assert game.game_state == :good_guess
    assert game.turns_left == 7
  end

  test "a guessed word is a won game" do
    moves = [
      {"w", :good_guess, 7},
      {"i", :good_guess, 7},
      {"b", :good_guess, 7},
      {"l", :good_guess, 7},
      {"e", :won, 7},
    ]
    game = Game.new_game("wibble")
    Enum.reduce(moves, game, fn({guess, state, turns_left}, new_game) ->
      {new_game, _tally} = Game.make_move(new_game, guess)
      assert new_game.game_state == state
      assert new_game.turns_left == turns_left
      new_game
    end)
  end

  test "bad guess is recognized" do
    game = Game.new_game("wibble")
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "bad guess loses game" do
    moves = [
      {"w", :bad_guess, 6},
      {"i", :bad_guess, 5},
      {"b", :bad_guess, 4},
      {"l", :bad_guess, 3},
      {"a", :bad_guess, 2},
      {"c", :bad_guess, 1},
      {"e", :lost, 0}
    ]
    game = Game.new_game("xxxxx")
    Enum.reduce(moves, game, fn({guess, state, turns_left}, new_game) ->
      {new_game, _tally} = Game.make_move(new_game, guess)
      assert new_game.game_state == state
      assert new_game.turns_left == turns_left
      new_game
    end)
  end
end
