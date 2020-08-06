defmodule ImageUploader.S3Uploader.BandwidthControl do
  use GenServer

  @name __MODULE__
  @max_bandwidth_consumption_bytes 12000

  defmodule State do
    @moduledoc """
      Struct for DeskTime Manager State
    """
    defstruct consumption: 0,
              image_process: 0,
              pending_consumers: %{}
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
  def reserve_bandwidth(image) do
    GenServer.call(@name, {:reserve_bandwidth, image})
  end

  @doc """
  Check if current consumption bandwidth + file size exceeds the maximum permitted
  And if it not exceeds reserve the file_size
  """
  # def check_and_reserve_bandwidth(file_size) do
  #   GenServer.call(@name, {:check_and_reserve_bandwidth, file_size})
  # end

  @doc """
  Free the file_size of the current consumption bandwidth
  """
  def free_bandwidth(file_size) do
    GenServer.call(@name, {:free_bandwidth, file_size})
  end

  ## GenServer Callbacks

  @impl true
  def init(_) do
    :timer.send_interval(500, :print_consumption)
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
        {:check_and_reserve_bandwidth, file_size},
        _from,
        %State{consumption: consumption} = state
      ) do
    {exceeds, new_state} =
      exceeds_bandwidth?(consumption, file_size)
      |> sum_bandwidth(file_size, state)

    {:reply, exceeds, new_state}
  end

  @impl true
  def handle_call(
        {:reserve_bandwidth, image},
        {from_pid, from_term},
        %State{consumption: consumption} = state
      ) do

    file_size = image[:size_file]
    # pending_consumers = pending_consumers |> Map.put(consumer, {file_size, false})
    new_state = %State{state | consumption: consumption + file_size}

    Process.send(from_pid, {:send_image, image}, [])
    {:reply, [], new_state}
  end

  @impl true
  def handle_call(
        {:free_bandwidth, file_size},
        _form,
        %State{consumption: consumption, image_process: image_process} = state
      ) do
    new_state = %State{
      state
      | consumption: consumption - file_size,
        image_process: image_process + 1
    }

    {:reply, :ok, new_state}
  end

  # def handle_info(
  #       :notify_to_consumers,
  #       %State{pending_consumers: pending_consumers} = state
  #     ) do

  #   for {consumer, {file_size, notify_flag}} <- pending_consumers do

  #   end

  #   {:noreply, state}
  # end

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

  defp sum_bandwidth(true, _file_size, state), do: {true, state}

  defp sum_bandwidth(
         false,
         file_size,
         %State{consumption: consumption} = state
       ) do
    state = %State{state | consumption: consumption + file_size}
    {false, state}
  end
end
