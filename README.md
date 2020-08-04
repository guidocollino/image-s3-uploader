# ImageUploader

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `image_uploader` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:image_uploader, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/image_uploader](https://hexdocs.pm/image_uploader).




 curl --request POST     --url http://localhost:8085/images/upload_fake     --header 'content-type: multipart/form-data;'     --form device_id=999     --form file_image=new_image


 seq 1 100000 | xargs -n1 -P 150 bash -c "curl --request POST \
    --url http://localhost:8085/images/upload_fake \
    --header 'content-type: multipart/form-data;' \
    --form device_id=999 \
    --form image=new_image"