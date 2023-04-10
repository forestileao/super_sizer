defmodule SuperSizer.ImageResize.ResizeWorker do
  use GenServer
  import Mogrify

  @size_limit "500x500"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, nil}
  end

  def resize_image(input_dir, output_dir, filename) do
    GenServer.call(__MODULE__, {
      :resize_image,
      input_dir: input_dir,
      output_dir: output_dir,
      filename: filename
    })
  end

  # Callbacks

  def handle_call({:resize_image, [input_dir: input_dir, output_dir: output_dir, filename: filename]}, _from, state) do
    input_path = Path.join([input_dir, filename])
    output_path = Path.join([output_dir, filename])

    open(input_path)
    |> resize_to_limit(@size_limit)
    |> save(path: output_path)

    {:reply, output_path, state}
  end
end
