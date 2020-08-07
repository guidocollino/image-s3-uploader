defmodule ImageUploader.Controller do
  alias ImageUploader.S3Uploader.Producer
  alias ImageUploader.Structs.Image

  def image_upload(_data) do
    # TODO change it with real data
    device_id = Enum.random(1..1000)
    id_image = Enum.random(1..10000)
    size_file = Enum.random(512..6144)

    image = %Image{
      id: id_image,
      device_id: device_id,
      size: size_file
    }

    Producer.add_image(image)
  end
end
