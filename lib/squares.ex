defmodule Squares do
  @moduledoc """
  The problem goes like this:
  Given n, k, we need to find sequences of k real numbers between 1 and n,
  such that the sum of individual squares of the numbers in the sequence,
  is a perfect square.
  Ex1: n = 5, k = 2
  Sol: 3
  Explanation: 3^2 + 4^2 = 25 which is 5^2
  Ex2: n = 10, k = 24
  Sol: 1
  9
  Explanation: 1^2 + 2^2 +.... 24^2 = 70^2
  9^2 + 10^2 + 11^2 + .....32^2 = a perfect square
  """

  def pidcreate do
    receive do
      {:proc, pid} -> [pid | pidcreate()]
    after
      1_000 -> []
    end
  end

  def init(num_proc, size, k) when num_proc == 1 do
    {:ok, procid} = Checker.start_link()
    {:ok, pid} = Summer.start_link({self(), procid, size, k})
    # IO.inspect(pid)
    send(self(), {:proc, pid})
    [procid]
  end

  def init(num_proc, size, k) do
    {:ok, procid} = Checker.start_link()
    {:ok, pid} = Summer.start_link({self(), procid, size, k})
    # IO.inspect(pid)
    send(self(), {:proc, pid})
    [procid | init(num_proc - 1, size, k)]
  end

  def get_next_pid_with_timeout do
    receive do
      {:proc, pid} -> pid
    after
      0_200 ->
        nil
        #    IO.puts("All Summers terminated!!!")
    end
  end

  def get_next_pid() do
    receive do
      {:proc, pid} -> pid
    end
  end

  def terminate_all() do
    pid = get_next_pid_with_timeout()

    if is_pid(pid) do
      Process.exit(pid, :normal)
    end
  end

  def terminate_all(pids) when pids == [] do
  end

  def terminate_all(pids) do
    Process.exit(hd(pids), :normal)
    terminate_all(tl(pids))
  end

  def start_proc(n, max_n, chunk_size) when n >= max_n - chunk_size do
    pid = get_next_pid()
    # IO.inspect(pid)
    GenServer.call(pid, {:final, n + 1, max_n - n})
    # IO.puts("terminating")
    terminate_all()
  end

  def start_proc(n, max_n, chunk_size) do
    pid = get_next_pid()
    # IO.inspect(pid)
    GenServer.cast(pid, {:start, n + 1})
    start_proc(n + chunk_size, max_n, chunk_size)
  end

  def add_pids_to_queue(pids) when pids == [] do
    nil
  end

  def add_pids_to_queue(pids) do
    [{_, sup_pid}] = Registry.lookup(:pids, :super)
    send(sup_pid, {:proc, hd(pids)})
    add_pids_to_queue(tl(pids))
  end

  def listen_stuff() do
    receive do
      {:new_node, pids} ->
        add_pids_to_queue(pids)
        listen_stuff()
    after
      10_000 -> :nothing
    end
  end

  def send_pid(:aas, p_list, pids) do
    # send_pid(tl(p_list),pids)
    send(p_list, {:new_node, pids})
  end

  def send_pid(pids, pid) do
    [{_, p_list}] = Registry.lookup(:pids, :spawned)
    send_pid(:aas, p_list, pids)
    [{_, new_pid}] = Registry.lookup(:pids, :super)
    send(pid, {:super_pid, new_pid})
  end

  def sendfuture(sup_pid) do
    receive do
      {:proc, pid} ->
        send(sup_pid, {:proc, pid})
        sendfuture(sup_pid)
    after
      15_000 -> IO.puts("over")
    end
  end

  def getsuper do
    receive do
      {:super_pid, pid} -> pid
    end
  end

  @doc """
  The main method of the problem. This is where the execution begins.
  This function acts as a supervisor and handles all the concurrent processes

  n,k -> the n and k from the problem statement
  """
  def main2(k) do
    num_proc = 25
    #    if n<50 do
    #        num_proc = 2
    #    end
    chunk_size = 10000
    # map = ProcListAgent.start_link
    proc_list = init(num_proc, chunk_size, k)
    pids = pidcreate()
    Node.spawn(:"bar@192.168.43.79", Squares, :send_pid, [pids, self()])
    pid = getsuper()
    sendfuture(pid)
    terminate_all(proc_list)
  end

  @doc """
  The main method of the problem. This is where the execution begins.
  This function acts as a supervisor and handles all the concurrent processes

  n,k -> the n and k from the problem statement
  """
  def main(n, k) do
    num_proc = 25
    chunk_size = 10000

    Registry.start_link(keys: :unique, name: :pids)
    Registry.register(:pids, :super, self())

    proc_list = init(num_proc, chunk_size, k)
    pid = spawn(fn -> listen_stuff() end)

    Registry.register(:pids, :spawned, pid)
    # listen_stuff()
    start_proc(0, n, chunk_size)
    # IO.puts("completed")
    terminate_all(proc_list)

    # IO.puts("completed")
  end

  def check_ans(n, k) when k == 1 do
    n * n
  end

  def check_ans(n, k) do
    n * n + check_ans(n + 1, k - 1)
  end
end
