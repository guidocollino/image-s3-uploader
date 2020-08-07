defmodule ImageUploader.Router do
  use Plug.{Debugger, Router}
  require Logger
  # plug(Plug.Logger, log: :debug)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:multipart],
    pass: ["*/*"]
  )

  plug(:dispatch)

  post "/api/images/upload" do
    {status, message} =
      case conn.body_params do
        %{"device_id" => _device_id, "image" => _image} = params ->
          ImageUploader.Controller.image_upload(params)
          {200, "Image recived"}

        _ ->
          {401, "Bad Request"}
      end

    send_resp(conn, status, message)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
