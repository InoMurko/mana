defmodule Itest.StartRelease do
  use GenStateMachine, callback_mode: [:state_functions, :state_enter]

  def start_link() do
    GenStateMachine.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_link(args) do
    GenStateMachine.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init([]) do
    data = %{}
    {:ok, :find_and_extract_release, data, {:next_event, :internal, :find_and_extract_release}}
  end

  def find_and_extract_release(:enter, :find_and_extract_release, _data) do
    dir = Path.join(System.cwd(), "/../../")

    payload = recursive_search(dir, "mana.tar.gz")

    {:next_state, :find_and_extract_release, payload}
  end

  def find_and_extract_release(:internal, :find_and_extract_release, path) do
    untar_path = '/tmp/mana/'
    :ok = :erl_tar.extract(String.to_charlist(path), [{:cwd, untar_path}, :compressed])
    start_path = recursive_search(untar_path, "mana")
    GenServer.start(Itest.TestRelease, start_path)
    {:stop, :normal}
  end

  defp recursive_search(dir, find_file) do
    try do
      do_recursive_search(dir, find_file)
    catch
      :throw, payload ->
        payload
    end
  end

  def do_recursive_search(dir, find_file) do
    Enum.find(
      File.ls!(dir),
      fn
        ^find_file ->
          throw(Path.join([dir, find_file]))

        file ->
          fname = "#{dir}/#{file}"
          if File.dir?(fname), do: do_recursive_search(fname, find_file)
      end
    )
  end
end
