defmodule ImageUploader.S3Uploader.ConsumersSupervisor do
  use ConsumerSupervisor
  alias ImageUploader.S3Uploader.{Producer, Uploader}

  def start_link(arg) do
    ConsumerSupervisor.start_link(__MODULE__, arg)
  end

  def init(_arg) do
    children = [%{id: Uploader, Uploader: {Uploader, :start_link, []}, restart: :transient}]
    opts = [strategy: :one_for_one, subscribe_to: [{Producer, max_demand: 50}]]
    ConsumerSupervisor.init(children, opts)
  end
end
