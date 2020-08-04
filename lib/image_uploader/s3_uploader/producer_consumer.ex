defmodule ImageUploader.S3Uploader.ProducerConsumer do
  use GenStage
  alias ImageUploader.S3Uploader.{Producer, BandwidthControl}

  def start_link(_) do
    GenStage.start_link(__MODULE__, :state, name: __MODULE__)
  end

  def init(state) do
    # send(self(), :init)
    {:producer_consumer, state, subscribe_to: [Producer]}
  end

  def handle_events(events, _form, state) do
    IO.inspect(events, label: "PRODUCER CONSUMER DEMAND")
    for event <- events do
      size_file = event[:size_file]
      if BandwidthControl.exceeds_bandwidth?(size_file) do
        IO.puts("exedio")
      else
        IO.puts("NO exedio")
      end
      BandwidthControl.add_bandwidth(size_file)
      IO.inspect(event)
    end
    {:noreply, events, state}
  end

end
