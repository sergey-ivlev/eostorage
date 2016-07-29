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

        # ttl test (with ttl default variable 5 seconds)
        :timer.sleep(6000);
        response = HTTPotion.get "localhost:8080/storage?key=somekey"
        assert HTTPotion.Response.success?(response) == true
        assert response.body == "{}"
  end

  test "ttl custom test" do
      # ttl test (with ttl custom value 3 seconds)
      header = [{"Accept", "application/json"},
                        {"Content-Type", "application/json"}]
      body = <<"key=somekey2&value=somevalue2&ttl=3">>
      response = HTTPotion.post "localhost:8080/storage", [body: body, headers: header]
      assert response.status_code == 201
      response = HTTPotion.get "localhost:8080/storage?key=somekey2"
      assert HTTPotion.Response.success?(response) == true
      assert response.body == "{\"key\":\"somekey2\",\"value\":\"somevalue2\"}"

      # sleep plus one second
      :timer.sleep(5000);
      response = HTTPotion.get "localhost:8080/storage?key=somekey2"
      assert HTTPotion.Response.success?(response) == true
      assert response.body == "{}"
  end
end
