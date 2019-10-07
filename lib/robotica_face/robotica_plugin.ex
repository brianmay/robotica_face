defmodule RoboticaFace.RoboticaPlugin do
  @moduledoc false

  use GenServer
  use RoboticaPlugins.Plugin
  require Logger

  defmodule State do
    @type t :: %__MODULE__{
    }
    defstruct []
  end

  def init(_opts) do
    {:ok, %State{}}
  end

  def config_schema do
    %{}
  end

  def handle_cast({:execute, action}, state) do
    RoboticaFace.Execute.execute(action)
    {:noreply, state}
  end

end
