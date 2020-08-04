defmodule ImageUploader.S3Uploader.Producer do
  use GenStage
  alias ImageUploader.S3Uploader.{Consumer, ConsumersSupervisor, ProducerConsumer}

  @count_consumers 3

  def start_link(init \\ []) do
    GenStage.start_link(__MODULE__, init, name: __MODULE__)
  end

  def init(state) do
    # send(self(), :init_consumers)
    {:producer, state}
  end

  def handle_info(:init_consumers, state) do
    ConsumersSupervisor.add_consumer(ProducerConsumer)

    Enum.each(1..@count_consumers, fn(_) ->
      ConsumersSupervisor.add_consumer(Consumer)
    end)

    {:noreply, [], state}
  end

  def handle_demand(demand, state) when demand > 0 do
    IO.puts("DEMAND TO PRODUCER #{demand}")
    {images, new_state} = state |> Enum.split(demand)
    {:noreply, images, new_state}
  end

  @doc """
  Adds new events
  """
  def add(events), do: GenServer.cast(__MODULE__, {:add, events})

  def handle_cast({:add, events}, state) when is_list(events) do
    # TODO chequer buffer si esta a cierto nivel levantar otro producer consumer

    {:noreply, events, state}
  end
  def handle_cast({:add, events}, state) do
    {:noreply, [events], state}
  end
end
