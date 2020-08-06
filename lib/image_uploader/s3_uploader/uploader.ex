defmodule ImageUploader.S3Uploader.Uploader do
  alias ImageUploader.S3Uploader.BandwidthControl

  def start_link(event) do
    # Note: this function must return the format of `{:ok, pid}` and like
    # all children started by a Supervisor, the process must be linked
    # back to the supervisor (if you use [`Task.start_link/1`](https://hexdocs.pm/elixir/Task.html#start_link/1) then both
    # these requirements are met automatically)
    Task.start_link(fn ->
      size_file = event[:size_file]
      # BandwidthControl.add_bandwidth(size_file)
      Process.sleep(500)
      # IO.inspect(self(), label: "CONSUMER PID")
      # IO.inspect(event, label: "IMAGE")
      BandwidthControl.free_bandwidth(size_file)
    end)
  end
end
