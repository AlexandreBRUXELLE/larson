defmodule LarsonWeb.Rabbit do

    def wait_for_messages(_channel, correlation_id) do
      IO.puts "Rabbit. wait "
      receive do
        {:basic_deliver, payload, %{correlation_id: ^correlation_id}} ->
          payload
      end
    end

    def call(message) do
      IO.puts "Rabbit. open "

      {:ok, connection} = AMQP.Connection.open
      {:ok, channel} = AMQP.Channel.open(connection)

      IO.puts "Rabbit. declare "

      {:ok, %{queue: queue_name}} = AMQP.Queue.declare( channel,
                                                        "",
                                                        exclusive: true)
      IO.puts "Rabbit. consume "
      AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)
      correlation_id =
        :erlang.unique_integer
        |> :erlang.integer_to_binary
        |> Base.encode64

      #request = message
      IO.puts "Rabbit. publish #{correlation_id}"

      AMQP.Basic.publish(channel,
                          "",
                          "rpc_queue",
                          message,
                          reply_to: queue_name,
                          correlation_id: correlation_id)

      LarsonWeb.Rabbit.wait_for_messages(channel, correlation_id)
    end


end
