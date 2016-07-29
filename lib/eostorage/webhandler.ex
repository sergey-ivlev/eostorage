import Monad
import ErrorM

defmodule Eostorage.Webhandler do
  def init(_transport, req, []) do {:ok, req, :undefined} end

  def handle(req, state) do
    {method, req2} = :cowboy_req.method(req)
    {ok, req3} =
      case method do
        <<"POST">> ->
          hasBody = :cowboy_req.has_body(req2)
          process_post(hasBody, req2)
        <<"GET">> ->
          {key, req3} = :cowboy_req.qs_val(<<"key">>, req2)
          process_get(key, req2)
        _ ->
          #method not allowed.
          :cowboy_req.reply(405, req)
      end
    {ok, req3, state}
  end

  def terminate(_Reason, _req, _state) do :ok end

  #  ----------------------------------------------
  #  --------------private functions---------------
  #  ----------------------------------------------
  defp process_post(true, req) do
    {:ok, postVals, req2} = :cowboy_req.body_qs(req)
    case getdata postVals do
      {:ok, {key, value, ttl}} ->
        create(key, value, ttl, req2)
      {:error, {code, reason}} ->
        :cowboy_req.reply(code, [], reason, req2)
    end
  end
  defp process_post(false, req) do
    :cowboy_req.reply(400, [], <<"Missing body.">>, req)
  end

  defp create(key, value, ttl, req) do
    case :etslib.put(:storage, key, value, ttl) do
      :ok ->
        :cowboy_req.reply(201, [{<<"content-type">>, <<"text/plain; charset=utf-8">>}], <<"created">>, req)
      res ->
        body = to_json([{:result, res}])
        :cowboy_req.reply(500, [{<<"content-type">>, <<"text/plain; charset=utf-8">>}], body, req)
    end
  end

  defp process_get(:undefined, req) do
  	:cowboy_req.reply(400, [], <<"Missing key parameter.">>, req)
  end
  defp process_get(key, req) do
    r = to_json(get(key))
  	:cowboy_req.reply(200, [{<<"content-type">>, <<"text/plain; charset=utf-8">>}], r, req)
  end

  defp get(key) do
     case :etslib.get(:storage, key) do
         {:ok, v} -> %{:key => key, :value => v}
         {:error, :undefined} -> %{}
     end
  end

  defp to_json(data) do
    try do
        :jsx.encode(data)
    rescue
        _ ->
            :io.format "jsx bad term: ~p~n", [data]
            <<>>
    end
  end

  defp getdata postVals do
    (Monad.monad ErrorM do
        key <- getkey postVals
        value <- getvalue postVals
        ttl <- getttl postVals
        {:ok, {key, value, ttl}}
    end)

  end
  defp getkey postVals do
    case :proplists.get_value(<<"key">>, postVals) do
      :undefined -> {:error, {400, <<"Missing key parameter.">>}}
      v -> {:ok, v}
    end
  end
  defp getvalue postVals do
    case :proplists.get_value(<<"value">>, postVals) do
      :undefined -> {:error, {400,  <<"Missing value parameter.">>}}
      v -> {:ok, v}
    end
  end
  defp getttl postVals do
    ttl = :proplists.get_value(<<"ttl">>, postVals)
    case ttl do
      :undefined ->
         {:ok, ttl}
      int when is_integer int ->
         {:ok, int}
      binint when is_binary binint ->
         case Integer.parse(binint, 10) do
           {intttl, _} ->
             {:ok, intttl}
           :error ->
             {:error, {400, <<"Wrong ttl parameter.">>}}
         end
      _ ->
         {:error, {400, <<"Wrong ttl parameter.">>}}
    end
  end

end
