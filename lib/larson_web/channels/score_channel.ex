defmodule LarsonWeb.ScoreChannel do
  use LarsonWeb, :channel

  def join("score:platformer", _payload, socket) do
    IO.puts "join"
    {:ok, socket}
  end

  def handle_in("broadcast_score", payload, socket) do


    #broadcast(socket, "broadcast_score", payload)
    #{list} =
    #%{"player_score"=>%{"cmd"=>cmd, "fsx"=>fsx, "params"=>params}}=payload

    #IO.puts " [x] Requesting (#{Jason.decode!(payload)})"
    IO.puts "handle [x] Requesting"

    mystr = Jason.encode!(payload)
    IO.puts " [x] Requesting (#{mystr})"

    #IO.puts " [x] Requesting (#{Jason.encode!(%{"cmd" => "build", "fsx" => "build.fsx", "params" => " "})}) "
    response = LarsonWeb.Rabbit.call(mystr)
    IO.puts "handle [.] Got #{response}"

    {:noreply, socket}
  end



end
