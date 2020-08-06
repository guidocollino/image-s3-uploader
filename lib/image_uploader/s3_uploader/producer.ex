defmodule ImageUploader.S3Uploader.Producer do
  use GenStage

  def start_link(init \\ []) do
    GenStage.start_link(__MODULE__, init, name: __MODULE__)
  end

  def init(state) do
    {:producer, state, buffer_size: :infinity}
  end

  def handle_demand(demand, state) when demand > 0 do
    {images, new_state} = state |> Enum.split(demand)
    {:noreply, images, new_state}
  end

  @doc """
  Adds new events
  """
  def add(events), do: GenServer.cast(__MODULE__, {:add, events})

  def handle_cast({:add, events}, state) when is_list(events) do
    {:noreply, events, state}
  end

  def handle_cast({:add, events}, state) do
    {:noreply, [events], state}
  end
end
