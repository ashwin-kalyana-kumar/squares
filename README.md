# Squares

Distributed Operating Systems COP5612, Fall 2018

Project to calculate if sum of squares of k consecutive integers is a perfect square.
Input of the form n k is given.

#Group Information

Name: Ashwin Kalyana Kumar, UFID: 13517733
Name: Jinansh Rupesh Patel, UFID: 94318155 

## Installation

There is no need for installation.
To run the project on a machine that has Elixir and Mix, unzip the files and run the following
from the 'squares' folder

`mix run startscript.exs N k`
(insert proper integer values in N and k)
Expected output: Integers for which sum of squares of (integer)+k-1 consecutive
integers is a perfect square.

Eg:
Sample Input: `mix run startscript.exs 100 24`
Sample Output:  1
                9
                20
                25
                44
                76

Explanation: 1^2 + 2^2 +...+ 24^2 = 70^2 and so on.

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `squares` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:squares, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/squares](https://hexdocs.pm/squares).

## Size of the work unit
10000 -> We decided upon this number because we wanted a workunit large enough that
 	 the process doesnt complete before the master process has assigned a workunit
	 for all of the concurrent running processes. Also the workunit should not be
	 so large that it takes a lot of time to complete its execution. After testing
	 few found the required number to be around 10000.
##Largest problem
The largest problem we managed to solve on a single machine was 100000000, 24.
We were testing it with k = 24 always as it was constantly producing some output.
the output is:
1
128601
20425
30908
54032
9
20
25
44
76
12981
121
306060
197
353585
304
202289
353
35709
540
856
1301
2053
84996
3112
3597
534964
5448
8576
841476
1273121
2002557
3029784
3500233
5295700
8329856
12602701
19823373
29991872
34648837
52422128
82457176
## Performance

To check the Performance, we will use the inbuilt time functionality.

`time mix run startscript.exs N k`

Eg: Sample Input: `time mix run startscript.exs 1000000 24`
Sample output:
12981
54032
20425
30908
128601
1
9
20
84996
25
44
76
121
197
304
353
540
35709
856
1301
202289
306060
2053
353585
3112
3597
5448
8576
534964
841476

real	0m1.362s
user	0m4.088s
sys	0m0.216s

ratio: (sys + user) / real
sample ratio: (4.088 + 0.216) / 1.362 = 3.16

Problem statement Input: `time mix run startscript.exs 1000000 4`
Problem statement Output:

real	0m1.362s
user	0m4.088s
sys	0m0.216s

Ratio: (4.348 + 0.204) / 1.492 = 3.05


#Bonus Implementaion
This program can be copied to any number of machines and the process will be distributed across all the machines connected. 
Even when the problem is being solved, a new machine can be added to the network and can run processes.
The master machine will run the main() method with N and K as parameters, 
all the slave machine will run the main2() method with only K. 
All the slave nodes, will create the GenServer processes, locally and will send the PID to the Master Process using Elixir's message queues
The master process will use the PID to assign a chunk of data to be processed to the process in the slave node. 
We tried connecting 3 machines and we were able to solve 500000000, 24. But as this program  is easily scalable to 'n' machines, there should theoretically be no upper limit on the largest solvable problem



