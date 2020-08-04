defmodule ImageUploader.Controller do
  alias ImageUploader.S3Uploader.Producer

  def image_upload(%{"device_id" => device_id, "image_file" => image_file}) do
    IO.puts("CONTROLLER")
    event = {device_id, image_file}
    Producer.add(event)
  end

  def image_upload(data) do
    id_image = Enum.random(1..10000)
    event = %{device_id: 1, image_id: id_image, file: "prueba" , size_file: 4096}
    Producer.add(event)
  end

end
