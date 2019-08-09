defmodule LarsonWeb.ScoreChannel do
  use LarsonWeb, :channel

  def join("score:platformer", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("broadcast_score", payload, socket) do
    broadcast(socket, "broadcast_score", payload)

    num =
      case System.argv do
        []    -> 30
        param ->
          {x, _} =
            param
            |> Enum.join(" ")
            |> Integer.parse
          x
      end

    IO.puts " [x] Requesting (#{num})"
    response = LarsonWeb.Rabbit.call(num)
    IO.puts " [.] Got #{response}"
    
    {:noreply, socket}
  end



end
