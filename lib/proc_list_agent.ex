defmodule ProcListAgent do
    use Agent

    def start_link do
        Agent.start_link(fn -> %{} end)
    end

    def update(map, key, val) do
        Agent.update(map, &Map.put(&1, key, val))
    end

    def read(map, key) do
        Agent.get(map, &Map.get(&1, key))
    end

end
