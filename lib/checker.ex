defmodule Checker do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, 0)
  end

  def init(state) do
    {:ok, state}
  end

  def search(sqr, l, h) when l <= h do
    m = div(l + h, 2)
    m_sqr = m * m

    cond do
      m_sqr == sqr -> :success
      m_sqr < sqr -> search(sqr, m + 1, h)
      m_sqr > sqr -> search(sqr, l, m - 1)
    end
  end

  def search(sqr, l, h) do
    :failure
  end

  def handle_cast({:sum, sum, v}, state) do
    if search(sum, state, sum) == :success do
      state = v
      IO.puts(v)
    end

    {:noreply, state}
  end

  def handle_call({:sum, sum, v}, _from, state) do
    if search(sum, state, sum) == :success do
      state = v
      IO.puts(v)
    end

    {:reply, :ok, state}
  end
end
