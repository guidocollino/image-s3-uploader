defmodule ImageUploader.S3Uploader.ProducerConsumer do
  use GenStage
  alias ImageUploader.S3Uploader.{Producer, BandwidthControl}

  def start_link(_) do
    GenStage.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:producer_consumer, :queue.new(),
     subscribe_to: [{Producer, max_demand: 1000, min_demand: 750}]}
  end

  def handle_events(events, _form, queue) do
    {events, queue} =
      events
      |> queue_events(queue)
      |> get_next_event()
      |> check_bandwidth()
      |> return_or_enqueu()

    IO.inspect(:queue.len(queue), label: "TAMAÑO COLA")

    {:noreply, events, queue}
  end

  defp queue_events(events, queue) do
    events_to_queue = events |> Enum.reverse() |> :queue.from_list()
    new_queue = queue |> :queue.join(events_to_queue)

    new_queue
  end

  defp get_next_event(queue) do
    case :queue.out(queue) do
      {{:value, event}, queue} ->
        {event, queue}

      {:empty, queue} ->
        {:empty, queue}
    end
  end

  defp check_bandwidth({:empty, queue}), do: {[], queue, false}

  defp check_bandwidth({event, queue}) do
    size_file = event[:size_file]
    exceeds = BandwidthControl.check_and_reserve_bandwidth(size_file)
    {event, queue, exceeds}
  end

  defp return_or_enqueu({[], queue, _}), do: {[], queue}

  defp return_or_enqueu({event, queue, true}) do
    queue = event |> :queue.in_r(queue)
    {[], queue}
  end

  defp return_or_enqueu({event, queue, false}) do
    {[event], queue}
  end
end
