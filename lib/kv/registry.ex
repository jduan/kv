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
  Stop the registry.
  """
  def stop(server) do
    GenServer.stop(server)
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
    {:ok, {%{}, %{}}}
  end

  def handle_call({:lookup, name}, _from, {names, refs}) do
    {:reply, Map.get(names, name), {names, refs}}
  end

  def handle_cast({:create, name}, {names, refs}) do
    case Map.get(names, name) do
      nil ->
        {:ok, pid} = KV.Bucket.start_link
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        names = Map.put(names, name, pid)
        {:noreply, {names, refs}}
      _pid ->
        {:noreply, {names, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    {:noreply, {Map.delete(names, name), refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
