defmodule Watcher.BeanstalkTest do
  use ExUnit.Case, async: true

  test "can parse a host:port string" do
    assert [host: 'myhost', port: 11300] == Watcher.Beanstalk.parse_connection("myhost:11300")
  end

  test "can parse a host string without a port" do
    assert [host: 'myhost'] == Watcher.Beanstalk.parse_connection("myhost")
  end

  test "opens and closes a connection when running a command" do
    Watcher.Beanstalk.run_and_close([host: 'localhost', port: 11300], fn (pid) ->
      send(self, {:callback_run, Process.alive?(pid), pid})
    end)

    assert_received {:callback_run, true, pid}
    monitor_ref = Process.monitor(pid)
    assert_receive {:DOWN, ^monitor_ref, :process, ^pid, :normal}
  end
end
