defmodule KV.Bucket do
  # public API
  @doc """
  Starts a new bucket.
  """
  def start_link do
    {:ok, pid} = Agent.start_link(fn -> %{} end)
  end

  # implementation
  @doc """
  Get a value from the bucket by `key`
  """
  def get(pid, key) do
    Agent.get(pid, fn m -> m[key] end)
  end

  @doc """
  Put a new value in the bucket for the given `key`
  """
  def put(pid, key, value) do
    Agent.update(pid, fn m -> Map.put(m, key, value) end)
  end
end
