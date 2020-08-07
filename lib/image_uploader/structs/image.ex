defmodule ImageUploader.Structs.Image do
  @moduledoc """
  This is a Struct to represent the data of an image
  """
  defstruct id: nil,
            path: nil,
            file: nil,
            device_id: nil,
            size: 0
end
