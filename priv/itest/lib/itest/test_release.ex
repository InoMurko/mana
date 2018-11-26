defmodule Itest.TestRelease do
  use GenServer

  def start(path) do
    GenServer.start_link(__MODULE__, path, name: __MODULE__)
  end

  def init(path) do

    port =
      :erlang.open_port({:spawn_executable, String.to_charlist(path)}, [
        :exit_status,
        :binary,
        :hide,
        {:args, ['run']}
      ])


    Process.flag(:trap_exit, true)
    true = Process.register(self(), __MODULE__)
    {:ok, Port.info(port)}
  end

  def handle_info({_port, {:data, data}}, state) do
    {:noreply, state}
  end

  def handle_info({_port, {:exit_status, 143}}, state) do
    {:stop, :normal, state}
  end

  def handle_info({_port, {:exit_status, 129}}, state) do
    #"outside HUP kill"
    {:stop, :normal, state}
  end
  def handle_info({_port, {:exit_status, 137}}, state) do
    #"outside -9 kill"
    {:stop, :normal, state}
  end
  def handle_info({_port, {:exit_status, 1}}, state) do
    {:stop, :normal, state}
  end

  def terminate(_, state) do
    # cleanup by killing the
    os_pid = Keyword.get(state, :os_pid)
    :os.cmd('pkill -15 -g #{os_pid}')
  end
end
