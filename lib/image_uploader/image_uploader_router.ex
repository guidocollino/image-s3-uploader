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

  post "/images/upload" do
    {:ok, body, conn} = read_body(conn)

    IO.inspect(body, label: "BODY PARAMS")

    ImageUploader.Controller.image_upload(body)

    # case body do
    #     %{"device_id" => device_id, "image_file" => image_file} -> {200, process_events(events)}
    #     _ -> {422, missing_events()}
    #   end

    # IO.inspect(body)

    send_resp(conn, 201, "OK")
  end

  post "/images/upload_fake" do
    {:ok, body, conn} = read_body(conn)

    ImageUploader.Controller.image_upload(body)

    send_resp(conn, 201, "OK")
  end

  # post "/events" do
  #   {status, body} =
  #     case conn.body_params do
  #       %{"events" => events} -> {200, process_events(events)}
  #       _ -> {422, missing_events()}
  #     end

  #   send_resp(conn, status, body)
  # end

  # "Default" route that will get called when no other route is matched

  match _ do
    send_resp(conn, 404, "not found")
  end
end
