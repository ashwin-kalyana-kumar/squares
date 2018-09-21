defmodule Summer do
  use GenServer

  @moduledoc """
  This module is named summer, not after the season, but because it 'sum's
  the values.
  This uses the GenServer module as a base and uses 'handle_cast' method to
  asynchronously add the values
  """
  @doc """
  The default start_link and init methods for the GenServer
  The structure of the state goes like this:
  {supervisor_pid, chunk_size, k}
  """
  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    {:ok, state}
  end

  def get_next_square(a, a_square) do
    a_square + 1 + a * 2
  end

  def get_square_sum(num) do
    div(num * (num + 1) * (2 * num + 1), 6)
  end

  def get_square_sum(first, last) do
    get_square_sum(last) - get_square_sum(first)
  end

  def get_square_sum(first, first_sqr, last, last_sqr, sum, stop_num, pid)
      when first == stop_num do
    GenServer.call(pid, {:sum, sum, first})
    #    spawn(fn -> Checker.search(sum, last, first_sqr, first) end)
  end

  def get_square_sum(first, first_sqr, last, last_sqr, sum, stop_num, pid) do
    #    IO.puts "#{first} , #{first_sqr} , #{last} ,#{last_sqr}, #{sum}"
    #    spawn(fn -> Checker.search(sum,last, sum, first) end)
    GenServer.cast(pid, {:sum, sum, first})
    sum = sum + last_sqr - first_sqr
    first_sqr = get_next_square(first, first_sqr)
    last_sqr = get_next_square(last, last_sqr)

    get_square_sum(first + 1, first_sqr, last + 1, last_sqr, sum, stop_num, pid)
  end

  @doc """
  for every execution, we just need to update the chunk_start. All other
  parameters remain the same
  """
  def handle_cast({:start, chunk_start}, state) do
    {pid, procid, size, k} = state
    first = chunk_start
    last = first + k
    sum = get_square_sum(first - 1, last - 1)
    get_square_sum(first, first * first, last, last * last, sum, first + size, procid)
    send(pid, {:proc, self()})
    {:noreply, state}
  end

  def handle_call({:final, chunk_start, chunk_size}, _from, state) do
    {pid, procid, size, k} = state
    size = chunk_size
    first = chunk_start
    last = first + k
    sum = get_square_sum(first - 1, last - 1)
    # IO.puts "sum #{sum}"
    get_square_sum(first, first * first, last, last * last, sum, first + size, procid)
    send(pid, {:proc, self()})
    {:reply, :done, state}
  end
end
