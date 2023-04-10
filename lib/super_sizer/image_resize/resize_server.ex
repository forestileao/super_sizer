defmodule SuperSizer.ImageResize.ResizeServer do
  use GenServer
  alias SuperSizer.ImageResize.ResizeWorker

  def start_link(%{input_dir: input_dir, output_dir: output_dir} = paths)
    when is_binary(input_dir) and is_binary(output_dir) do
    GenServer.start_link(__MODULE__, paths, name: __MODULE__)
  end

  def init(paths) do
    state =
      paths
      |> Map.merge(%{
        processed_images: 0,
        total_images: 0
      })

    {:ok, state}
  end

  def start_resizes do
    # send to resize pool an resize request
  end

  def increment_total do
    GenServer.cast(__MODULE__, {:increment_total})
  end

  # TODO: Finish when all processed_images == total_images
  # def end_process...

  # Callbacks

  def handle_call({:start_resizes}, _from, state) do
    %{input_dir: input_dir, output_dir: output_dir} = state
    image_filenames = File.ls!(input_dir)

    tasks = image_filenames
      |> Enum.map(fn filename ->
        Task.async(fn ->
          ResizeWorker.resize_image(input_dir, output_dir, filename)
          increment_total()
        end)
      end)

    newState = state |> Map.put(:tasks, tasks)

    {:reply, :ok, newState}
  end

  def handle_cast({:increment_total}, state) do
    new_state = state |> Map.update!(:processed_images, &(&1 + 1))
    {:noreply, new_state}
  end
end
