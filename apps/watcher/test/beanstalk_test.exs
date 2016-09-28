defmodule Watcher.BeanstalkTest do
  use ExUnit.Case, async: true

  test "can parse a host:port string" do
    assert [host: 'myhost', port: 11300] == Watcher.Beanstalk.parse_connection("myhost:11300")
  end

  test "can parse a host string without a port" do
    assert [host: 'myhost'] == Watcher.Beanstalk.parse_connection("myhost")
  end

  test "opens and closes a connection when running a command" do
    # TODO: use callback to do something with the pid
  end
end
