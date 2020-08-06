defmodule ImageUploader.S3Uploader.Consumer do
  use GenStage
  alias ImageUploader.S3Uploader.{Producer, BandwidthControl}

  def start_link(_) do
    GenStage.start(__MODULE__, :state)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [{Producer, max_demand: 1}]}
  end

  def handle_subscribe(:producer, opts, from, _state) do
    demand = opts[:max_demand] || 1
    ask_and_schedule(demand, from)

    {:manual, from}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      size_file = event[:size_file]
      BandwidthControl.reserve_bandwidth(event)
      IO.inspect(event, label: "IMAGE RESERVE")
      # Process.send(self(), {:send_image, event},[])
    end

    {:noreply, [], state}
  end

  # def handle_events(_events, _from, state), do: {:noreply, [], state}

  def handle_info({:send_image, image}, producer) do
    # if BandwidthControl.exceeds_bandwidth? do
    #   IO.puts("GANO OTRO CONSUMIDOR")
    #   Process.send_after(self(), {:send_image, image}, 1000)
    # else
    #   BandwidthControl.add_bandwidth(image[:size_file])
    IO.puts("IMAGE PROCESS")
    Process.sleep(500)
    BandwidthControl.free_bandwidth(image[:size_file])
    # end
    {:noreply, [], producer}
  end

  def handle_info({:ask, demand}, producer) do
    # This callback is invoked by the Process.send_after/3 message below.
    {:noreply, [], ask_and_schedule(demand, producer)}
  end

  defp ask_and_schedule(demand, producer) do
    unless BandwidthControl.exceeds_bandwidth?() do
      IO.puts("PUEDE DEMANDAR")
      GenStage.ask(producer, demand)
    else
      IO.puts("NO DEMANDAR")
    end

    Process.send_after(self(), {:ask, demand}, 1_000)
    producer
  end
end
