defmodule SuperSizer.Supervisor do
  use Supervisor
  alias SuperSizer.ImageResize.{ResizeServer, ResizeWorker}

  @input_dir "input/dir"
  @output_dir "output/dir"

  @poolboy_config [
      name: {:local, :resize_worker},
      worker_module: ResizeWorker,
      size: 20,
      max_overflow: 2
  ]

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      {
        ResizeServer, [%{
          input_dir: @input_dir,
          output_dir: @output_dir
        }]
      },
      :poolboy.child_spec(:resize_worker, @poolboy_config)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
