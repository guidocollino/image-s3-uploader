defmodule ImageUploader.S3Uploader.BandwidthControl do
  @moduledoc """
  This module must maintain the consumption of the bandwidth that is being used to send files
  and control that no more than the maximum allowed is used
  """
  use GenServer

  @name __MODULE__
  @max_bandwidth_consumption_bytes 12000
  @logger_time 2_000

  defmodule State do
    @moduledoc """
      Struct for BandwidthControl State
    """
    defstruct consumption: 0,
              image_process: 0
  end

  @doc """
  Starts the registry.
  """
  def start_link(_) do
    GenServer.start_link(@name, nil, name: @name)
  end

  @doc """
  Check if current consumption bandwidth + file size exceeds the maximum permitted
  """
  def exceeds_bandwidth?(file_size \\ 0) do
    GenServer.call(@name, {:exceeds_bandwidth, file_size})
  end

  @doc """
  Check if current consumption bandwidth + file size exceeds the maximum permitted
  And if it not exceeds reserve the file_size
  """
  def check_and_reserve_bandwidth(image) do
    GenServer.call(@name, {:check_and_reserve_bandwidth, image})
  end

  @doc """
  Free the file_size of the current consumption bandwidth
  """
  def free_bandwidth(file_size) do
    GenServer.cast(@name, {:free_bandwidth, file_size})
  end

  ## GenServer Callbacks

  @impl true
  def init(_) do
    :timer.send_interval(@logger_time, :print_consumption)
    {:ok, %State{}}
  end

  @impl true
  def handle_call(
        {:exceeds_bandwidth, file_size},
        _from,
        %State{consumption: consumption} = state
      ) do
    exceeds = exceeds_bandwidth?(consumption, file_size)
    {:reply, exceeds, state}
  end

  @impl true
  def handle_call(
        {:check_and_reserve_bandwidth, image},
        {from_pid, _from_term},
        %State{consumption: consumption} = state
      ) do
    file_size = image[:size_file]
    if exceeds_bandwidth?(consumption, file_size) do
      {:reply, :exceeds, state}
    else
      new_state = sum_bandwidth(file_size, state)
      Process.send(from_pid, {:send_image, image}, [])
      {:reply, :ok, new_state}
    end
  end

  @impl true
  def handle_cast(
        {:free_bandwidth, file_size},
        %State{consumption: consumption, image_process: image_process} = state
      ) do
    new_state = %State{
      state
      | consumption: consumption - file_size,
        image_process: image_process + 1
    }

    {:noreply, new_state}
  end

  def handle_info(
        :print_consumption,
        %State{consumption: consumption, image_process: image_process} = state
      ) do
    IO.inspect(consumption, label: "BAND CONSUM")
    IO.inspect(image_process, label: "COUNT IMAGE PROCESS")
    {:noreply, state}
  end

  defp exceeds_bandwidth?(consumption, file_size) do
    consumption + file_size > @max_bandwidth_consumption_bytes
  end

  defp sum_bandwidth(
         file_size,
         %State{consumption: consumption} = state
       ) do
    %State{state | consumption: consumption + file_size}
  end
end
