defmodule CLI.Config do
  @moduledoc """
  CLI.Config determines the configuration for a running
  Mana instance. For example, which database to use to store
  the block tree.
  """

  @doc """
  The name of the database (e.g. for RocksDB) to store loaded blocks in.
  ## Examples
      iex> CLI.Config.db_name(:ropsten)
      'db/mana-ropsten'
  """
  @spec db_name(atom()) :: nonempty_charlist()
  def db_name(chain_id) do
    path = "#{System.cwd!()}/db/mana-#{Atom.to_string(chain_id)}"
    dirname = Path.dirname(path)
    :ok = File.mkdir_p(dirname)

    "#{System.cwd!()}/db/mana-#{Atom.to_string(chain_id)}"
    |> String.to_charlist()
  end
end