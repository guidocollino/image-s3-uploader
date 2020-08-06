defmodule ImageUploader.S3Uploader.Consumer do
  use GenStage
  alias ImageUploader.S3Uploader.{Producer, ProducerConsumer, BandwidthControl}

  def start_link(_) do
    GenStage.start(__MODULE__, :state)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [{ProducerConsumer, max_demand: 1}]}
  end

  def handle_events(events, _from, state) when is_list(events) and length(events) > 0 do
    for event <- events do
      size_file = event[:size_file]
      # BandwidthControl.add_bandwidth(size_file)
      Process.sleep(500)
      # IO.inspect(self(), label: "CONSUMER PID")
      # IO.inspect(event, label: "IMAGE")
      BandwidthControl.free_bandwidth(size_file)
    end

    {:noreply, [], state}
  end

  def handle_events(_events, _from, state), do: {:noreply, [], state}
end
