defmodule LakeEffect.Application do
  use Application
  require Logger

  @sensor_base_dir "/sys/bus/w1/devices/"
  @sensor_id "28-0000081bfd1c"
  @sensor_path "#{@sensor_base_dir}#{@sensor_id}/w1_slave"

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # worker(LakeEffect.Worker, [arg1, arg2, arg3]),
    ]

    read_temp()

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LakeEffect.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def read_temp() do
    Logger.debug("Reading sensor: #{@sensor_path}")
    sensor_data = @sensor_path
                  |> File.read!
    {temp, _} = Regex.run(~r/t=(\d+)/, sensor_data)
    |> List.last
    |> Float.parse

    celsius = (temp / 1000)
    fahrenheit = ((celsius * 9)/5)+32
    Logger.debug "#{fahrenheit} *F"
    :timer.sleep(1000)
    read_temp()
  end
end
