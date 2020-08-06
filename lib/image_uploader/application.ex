defmodule ImageUploader.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Plug.Adapters.Cowboy.child_spec(
        scheme: :http,
        plug: ImageUploader.Router,
        options: [port: 8085]
      ),
      ImageUploader.S3Uploader.BandwidthControl,
      ImageUploader.S3Uploader.Producer,
      Supervisor.child_spec(ImageUploader.S3Uploader.Consumer, id: :c1),
      Supervisor.child_spec(ImageUploader.S3Uploader.Consumer, id: :c2),
      Supervisor.child_spec(ImageUploader.S3Uploader.Consumer, id: :c3),
      Supervisor.child_spec(ImageUploader.S3Uploader.Consumer, id: :c4),
      Supervisor.child_spec(ImageUploader.S3Uploader.Consumer, id: :c5)
    ]

    opts = [strategy: :one_for_one, name: ImageUploader.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
