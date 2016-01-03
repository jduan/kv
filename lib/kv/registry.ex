defmodule KV.Registry do
  use GenServer

  ## client API

  @doc """
  Start the registry.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Look up the bucket pid for name.

  Return pid if the bucket exists, nil otherwise
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensure there is a bucket associated with the given name.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  ## server callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.get(names, name), names}
  end

  def handle_cast({:create, name}, names) do
    new_names = case Map.get(names, name) do
      nil ->
        {:ok, pid} = KV.Bucket.start_link
        Map.put(names, name, pid)
      _pid ->
        names
    end
    {:noreply, new_names}
  end
end
