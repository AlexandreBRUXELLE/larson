defmodule LarsonWeb.ScoreChannel do
  use LarsonWeb, :channel

  def join("score:platformer", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("broadcast_score", %{"player_score" => player_score} = payload, socket) do

    #player_score=player_score+1
    #Io.puts ("player_score", ?\s, player_score)

    payload = %{
          player_score: player_score+ 1
    }

     broadcast(socket, "broadcast_score", payload)
    {:noreply, socket}
  end

end
