defmodule LarsonWeb.ScoreChannel do
  use LarsonWeb, :channel

  def join("score:platformer", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("broadcast_score", payload, socket) do

    broadcast(socket, "broadcast_score", payload)

    %{"player_score"=>player_score}=payload

    IO.puts " [x] Requesting (#{player_score})"
    response = LarsonWeb.Rabbit.call(player_score)
    IO.puts " [.] Got #{response}"

    {:noreply, socket}
  end



end
