defmodule ImageUploader.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger
  # plug(Plug.Logger, log: :debug)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison
  )

  plug(:dispatch)

  post "/api/images/upload" do
    {:ok, body, conn} = read_body(conn)

    ImageUploader.Controller.image_upload(body)

    send_resp(conn, 201, "OK")
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
