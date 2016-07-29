defmodule Eostorage.Webserver do
  @moduledoc false

  def start do
        dispatch = :cowboy_router.compile(routes())
        { :ok, _ } = :cowboy.start_http(:http,
                                        100,
                                       [{:port, 8080}],
                                       [{ :env, [{:dispatch, dispatch}]}]
                                       )
  end

  defp routes do
    [{ :_, [
            {"/", :cowboy_static, {:priv_file, :eostorage, "index.html"}},
            {"/storage", Eostorage.Webhandler, []}
            ]}]
  end

end
