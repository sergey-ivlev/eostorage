defmodule Eostorage.StorageTest do
  @moduledoc false

  use ExUnit.Case, async: true

  test "put/get by key" do
        assert :etslib.get(:storage, "unknownkey") == {:error, :undefined}

        :etslib.put(:storage, "somekey", :someatom)
        assert :etslib.get(:storage, "somekey") == {:ok, :someatom}

        :etslib.put(:storage, "somekey", :newatom)
        assert :etslib.get(:storage, "somekey") == {:ok, :newatom}
  end
end
