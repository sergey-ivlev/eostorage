defmodule EostorageTest do
  use ExUnit.Case
  doctest Eostorage

  test "put/get at resource" do
        response = HTTPotion.get "localhost:8080/storage?key=unknownkey"
        assert HTTPotion.Response.success?(response) == true
        assert response.body == "{}"

        header = [{"Accept", "application/json"},
                  {"Content-Type", "application/json"}]
        body = <<"key=somekey&value=somevalue">>
        response = HTTPotion.post "localhost:8080/storage", [body: body, headers: header]
        assert response.status_code == 201


        response = HTTPotion.get "localhost:8080/storage?key=somekey"
        assert HTTPotion.Response.success?(response) == true
        assert response.body == "{\"key\":\"somekey\",\"value\":\"somevalue\"}"

        # ttl test (with ttl variable 5 seconds)
        :timer.sleep(6000);
        response = HTTPotion.get "localhost:8080/storage?key=somekey"
        assert HTTPotion.Response.success?(response) == true
        assert response.body == "{}"

  end
end
