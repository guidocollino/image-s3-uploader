defmodule ImageUploader.S3Uploader.BandwidthControl do
  use GenServer

  @name __MODULE__
  @max_bandwidth_consumption_bytes 12000

  defmodule State do
    @moduledoc """
      Struct for DeskTime Manager State
    """
    defstruct [
      bandwidth_consumption: 0
    ]
  end

  @doc """
  Starts the registry.
  """
  def start_link(_) do
    GenServer.start_link(@name, nil, name: @name)
  end

  @doc """
  TODO
  """
  def exceeds_bandwidth?(file_size) do
    GenServer.call(@name, {:exceeds_bandwidth, file_size})
  end

  @doc """
  TODO
  """
  def add_bandwidth(file_size) do
    GenServer.cast(@name, {:add_bandwidth, file_size})
  end

  @doc """
  TODO
  """
  def free_bandwidth(file_size) do
    GenServer.cast(@name, {:add_bandwidth, file_size})
  end

  ## GenServer Callbacks

  @impl true
  def init(_) do
    {:ok, %State{}}
  end

  @impl true
  def handle_call({:exceeds_bandwidth, file_size}, _from, %State{bandwidth_consumption: bandwidth_consumption} = state) do
    exceeds = ((bandwidth_consumption + file_size) > @max_bandwidth_consumption_bytes)
    {:reply, exceeds, state}
  end

  @impl true
  def handle_cast({:add_bandwidth, file_size}, %State{bandwidth_consumption: bandwidth_consumption} = state) do
    IO.inspect(bandwidth_consumption, label: "ADD - BAND CONSUM")
    new_state = %State{ state | bandwidth_consumption: bandwidth_consumption + file_size }
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:free_bandwidth, file_size}, %State{bandwidth_consumption: bandwidth_consumption} = state) do
    IO.inspect(bandwidth_consumption, label: "FREE - BAND CONSUM")
    new_state = %State{ state | bandwidth_consumption: bandwidth_consumption - file_size }
    {:noreply, new_state}
  end
end
