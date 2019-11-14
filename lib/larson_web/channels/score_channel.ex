defmodule LarsonWeb.ScoreChannel do
  use LarsonWeb, :channel

  def join("score:platformer", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("broadcast_score", payload, socket) do

    broadcast(socket, "broadcast_score", payload)

    %{"player_score"=>%{"cmd"=>cmd, "fsx"=>fsx, "params"=>params}}=payload

    IO.puts " [x] Requesting (#{cmd} , #{fsx} , #{params})"
    response = LarsonWeb.Rabbit.call(payload)
    IO.puts " [.] Got #{response}"

    {:noreply, socket}
  end



end
