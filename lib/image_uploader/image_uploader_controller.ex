defmodule ImageUploader.Controller do
  alias ImageUploader.S3Uploader.Producer

  def image_upload(data) do
    # TODO change it with real data
    id_image = Enum.random(1..10000)
    size_file = Enum.random(512..6144)

    event = %{device_id: 1, image_id: id_image, file: "prueba" , size_file: size_file}
    Producer.add(event)
  end

end
