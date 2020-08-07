defmodule ImageUploader.S3Uploader.Consumer do
  @moduledoc """
  This is a consumer of images to send them to S3,
  works with manual demand consulting the bandwidth before request more images
  """
  use GenStage
  alias ImageUploader.S3Uploader.{Producer, BandwidthControl}
  alias ImageUploader.Structs.Image

  @demand_wait_time 2_000

  def start_link(_) do
    GenStage.start(__MODULE__, :state)
  end

  def init(state), do: {:consumer, state, subscribe_to: [{Producer, max_demand: 1}]}

  def handle_subscribe(:producer, opts, from, _state) do
    demand = opts[:max_demand] || 1
    ask_and_schedule(demand, from)

    {:manual, from}
  end

  def handle_events(images, _from, state) do
    for image <- images do
      check_and_send_image(image, nil)
    end

    {:noreply, [], state}
  end

  def handle_info({:send_image, %Image{size: image_size}}, producer) do
    sleep_time = round(image_size * 0.5)
    Process.sleep(sleep_time)
    BandwidthControl.free_bandwidth(image_size)
    {:noreply, [], producer}
  end

  def handle_info({:ask, demand}, producer) do
    {:noreply, [], ask_and_schedule(demand, producer)}
  end

  defp check_and_send_image(_image, :ok), do: []

  defp check_and_send_image(image, _status) do
    status_bandwidth = BandwidthControl.check_and_reserve_bandwidth(image)
    check_and_send_image(image, status_bandwidth)
  end

  # Demand the images unless the bandwidth consumption is exceeds
  defp ask_and_schedule(demand, producer) do
    BandwidthControl.exceeds_bandwidth?()
    |> try_to_demand(producer, demand)

    Process.send_after(self(), {:ask, demand}, @demand_wait_time)
    producer
  end

  defp try_to_demand(true, _producer, _demand), do: []
  defp try_to_demand(false, producer, demand), do: GenStage.ask(producer, demand)
end
