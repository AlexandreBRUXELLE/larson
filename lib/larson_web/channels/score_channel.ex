defmodule LarsonWeb.ScoreChannel do
  use LarsonWeb, :channel

  def join("score:platformer", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("broadcast_score", payload, socket) do

    broadcast(socket, "broadcast_score", payload)

    my_str = "zdadefezf"

    IO.puts " [x] Requesting (#{my_str})"
    response = LarsonWeb.Rabbit.call(my_str)
    IO.puts " [.] Got #{response}"

    {:noreply, socket}
  end



end
