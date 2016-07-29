defmodule Eostorage.EostorageSup do
  @moduledoc false
  
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    {:ok, ttl} = :application.get_env(:eostorage, :ttl)
    {:ok, check_timeout} = :application.get_env(:eostorage, :check_timeout)
    opts = [{:ttl, ttl},{:bucket, :storage},{:check_timeout, check_timeout}]
    children = [
      worker(:etslib, [opts])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
