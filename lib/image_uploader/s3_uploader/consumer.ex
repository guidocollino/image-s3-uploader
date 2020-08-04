defmodule ImageUploader.S3Uploader.Consumer do
  use GenStage
  alias ImageUploader.S3Uploader.{ProducerConsumer, BandwidthControl}

  def start_link(_) do
    GenStage.start(__MODULE__, :state)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [{ProducerConsumer, max_demand: 1}]}
  end

  def handle_events(events, _from, state) when is_list(events) and length(events) > 0 do
    IO.inspect(length(events), label: "EVENTOS")
    for event <- events do
      Process.sleep(2_000)
      size_file = event[:size_file]
      BandwidthControl.free_bandwidth(size_file)
    end
    {:noreply, [], state}
  end

  # def handle_events(_events, _from, state), do: {:noreply, [], state}
end
