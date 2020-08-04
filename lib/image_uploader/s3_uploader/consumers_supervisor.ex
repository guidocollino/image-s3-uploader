defmodule ImageUploader.S3Uploader.ConsumersSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)

  def add_consumer(consumer) do
    spec = {consumer, []}

    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
