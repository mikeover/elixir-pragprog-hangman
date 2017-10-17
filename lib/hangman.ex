defmodule Hangman do

  def new_game(difficulty) do
    # For some reason couldn't get the supervisor to pass data down to start_link so I just abandoned it
    #    { :ok, pid } = Supervisor.start_child(Hangman.Supervisor, [])
    { :ok, pid } = Hangman.Server.start_link([difficulty])
    pid
  end

  def tally(game_pid) do
    GenServer.call(game_pid, { :tally })
  end

  def make_move(game_pid, guess) do
    GenServer.call(game_pid, { :make_move, guess })
  end
end
