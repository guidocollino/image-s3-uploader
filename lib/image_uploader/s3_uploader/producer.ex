defmodule ImageUploader.S3Uploader.Producer do
  @moduledoc """
  This is a producer which receives images to store them
  and dispatch them when the consumers demands them
  """
  use GenStage

  def start_link(init \\ []) do
    GenStage.start_link(__MODULE__, init, name: __MODULE__)
  end

  def init(state) do
    {:producer, state, buffer_size: :infinity}
  end

  @doc """
  Adds new events (images) to its buffer
  """
  def add_image(images), do: GenServer.cast(__MODULE__, {:add_image, images})

  def handle_demand(demand, state) when demand > 0 do
    {images, new_state} = state |> Enum.split(demand)
    {:noreply, images, new_state}
  end

  def handle_cast({:add_image, images}, state) when is_list(images) do
    {:noreply, images, state}
  end

  def handle_cast({:add_image, image}, state) do
    {:noreply, [image], state}
  end
end
