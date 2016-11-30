defmodule Watcher.AggregatorTest do
  use ExUnit.Case

  test "can aggregate beanstalkd stats map" do
    input = [
     %{"current-jobs-urgent" => 1, "cmd-peek" => 10, "uptime" => 86771,
        "id" => "26cf413a5ddc253f", "cmd-put" => 1, "job-timeouts" => 0,
        "cmd-list-tubes" => 1, "cmd-stats-job" => 0, "cmd-peek-delayed" => 0},
      %{"current-jobs-urgent" => 2, "cmd-peek" => 1, "uptime" => 86771,
        "id" => "26cf413a5ddc253f", "cmd-put" => 0, "job-timeouts" => 0,
        "cmd-list-tubes" => 1, "cmd-stats-job" => 0, "cmd-peek-delayed" => 0},
    ]

    expected = %{"current-jobs-urgent" => 3, "cmd-peek" => 11, "uptime" => 86771,
      "id" => "n/a", "cmd-put" => 1, "job-timeouts" => 0,
      "cmd-list-tubes" => 2, "cmd-stats-job" => 0, "cmd-peek-delayed" => 0}

    assert expected == Watcher.Aggregator.summary(input)
  end

  test "can aggregate a collection of tube stats" do
    input = [
      [
        %{"name" => "tube1", "current-jobs-ready" => 10, "current-using" => 1},
        %{"name" => "tube2", "current-jobs-ready" => 1, "current-using" => 2},
        %{"name" => "tube3", "current-jobs-ready" => 2, "current-using" => 1}
      ],
      [
        %{"name" => "tube3", "current-jobs-ready" => 10, "current-using" => 1},
        %{"name" => "tube1", "current-jobs-ready" => 1, "current-using" => 2},
        %{"name" => "tube2", "current-jobs-ready" => 2, "current-using" => 1},
        %{"name" => "tube4", "current-jobs-ready" => 2, "current-using" => 1}
      ]
    ]

    expected = %{
      "tube1" => %{"current-jobs-ready" => 11, "current-using" => 3},
      "tube2" => %{"current-jobs-ready" => 3, "current-using" => 3},
      "tube3" => %{"current-jobs-ready" => 12, "current-using" => 2},
      "tube4" => %{"current-jobs-ready" => 2, "current-using" => 1}
    }

    assert expected == Watcher.Aggregator.summary(input)
  end

  test "can create a union of sets from all nodes" do
    input = [
      ["default", "tube2", "tube1", "tube3"],
      ["default", "tube1", "tube3", "tube4", "tube5"],
      ["default", "tube3"],
    ]

    expected = ["default", "tube1", "tube2", "tube3", "tube4", "tube5"]

    assert expected == Watcher.Aggregator.union(input)
  end
end
