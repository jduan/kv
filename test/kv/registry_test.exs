defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, registry} = KV.Registry.start_link
    # This is to show that a new registry process is created per test case!
    # IO.puts "registry #{inspect registry} created!"
    {:ok, registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "shopping") == nil

    KV.Registry.create(registry, "shopping")
    bucket = KV.Registry.lookup(registry, "shopping")
    assert bucket != nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "should be only one bucket per name", %{registry: registry} do
    assert KV.Registry.lookup(registry, "shopping") == nil

    KV.Registry.create(registry, "shopping")
    bucket1 = KV.Registry.lookup(registry, "shopping")

    KV.Registry.create(registry, "shopping")
    bucket2 = KV.Registry.lookup(registry, "shopping")
    assert bucket1 == bucket2
  end

  test "remove buckets on exit", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    bucket = KV.Registry.lookup(registry, "shopping")
    KV.Registry.stop(bucket)
    assert KV.Registry.lookup(registry, "shopping") == nil
  end
end
