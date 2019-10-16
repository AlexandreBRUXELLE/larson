defmodule LarsonWeb.Rabbit do

    def wait_for_messages(_channel, correlation_id) do
      IO.puts " wait "
      receive do
        {:basic_deliver, payload, %{correlation_id: ^correlation_id}} ->
          payload
          IO.puts " got : #{payload}"
      end
    end

    def call(message) do
      IO.puts " open "

      {:ok, connection} = AMQP.Connection.open
      {:ok, channel} = AMQP.Channel.open(connection)

      IO.puts " declare "

      {:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true)
      IO.puts " consume "
      AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)
      correlation_id = :erlang.unique_integer |> :erlang.integer_to_binary |> Base.encode64
      request = message
      IO.puts " publish #{correlation_id}"
      AMQP.Basic.publish(channel, "", "rpc_queue", request, reply_to: queue_name, correlation_id: correlation_id)

      LarsonWeb.Rabbit.wait_for_messages(channel, correlation_id)
      IO.puts " end  "
    end


end
