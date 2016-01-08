PerfAndPubTools
===============

1\.  [What is PerfAndPubTools?](#whatisperfandpubtools?)  
2\.  [Benchmark file format](#benchmarkfileformat)  
3\.  [Architecture and functions](#architectureandfunctions)  
4\.  [Examples](#examples)  
4.1\.  [Comparing sorting algorithms](#comparingsortingalgorithms)  
4.1.1\.  [Extract performance data from a file](#extractperformancedatafromafile)  
4.1.2\.  [Extract execution times from files in a folder](#extractexecutiontimesfromfilesinafolder)  
4.1.3\.  [Average execution times and standard deviations](#averageexecutiontimesandstandarddeviations)  
4.1.4\.  [Compare multiple setups within the same implementation](#comparemultiplesetupswithinthesameimplementation)  
4.1.5\.  [Same as previous, with a linear plot](#sameaspreviouswithalinearplot)  
4.1.6\.  [Compare different implementations](#comparedifferentimplementations)  
4.1.7\.  [Speedup](#speedup)  
4.1.8\.  [Speedup for multiple algorithms and vector sizes](#speedupformultiplealgorithmsandvectorsizes)  
4.1.9\.  [Scalability of the different sorting algorithms for increasing vector sizes](#scalabilityofthedifferentsortingalgorithmsforincreasingvectorsizes)  
4.1.10\.  [Produce a table instead of a plot](#produceatableinsteadofaplot)  
4.2\.  [Replicating results of an existing publication](#replicatingresultsofanexistingpublication)  
4.2.1\.  [Extract performance data from a file](#extractperformancedatafromafile-1)  
4.2.2\.  [Extract execution times from files in a folder](#extractexecutiontimesfromfilesinafolder-1)  
4.2.3\.  [Average execution times and standard deviations](#averageexecutiontimesandstandarddeviations-1)  
4.2.4\.  [Compare multiple setups within the same implementation](#comparemultiplesetupswithinthesameimplementation-1)  
4.2.5\.  [Same as previous, with a log-log plot](#sameaspreviouswithalog-logplot)  
4.2.6\.  [Compare different implementations](#comparedifferentimplementations-1)  
4.2.7\.  [Speedup](#speedup-1)  
4.2.8\.  [Speedup for multiple parallel implementations and sizes](#speedupformultipleparallelimplementationsandsizes)  
4.2.9\.  [Scalability of the different implementations for increasing model sizes](#scalabilityofthedifferentimplementationsforincreasingmodelsizes)  
4.2.10\.  [Scalability of parallel implementations for increasing number of threads](#scalabilityofparallelimplementationsforincreasingnumberofthreads)  
4.2.11\.  [Performance of OD strategy for different values of _b_](#performanceofodstrategyfordifferentvaluesof_b_)  
4.2.12\.  [Same as example 6, but show a table instead of a plot](#sameasexample6butshowatableinsteadofaplot)  
4.2.13\.  [Complex tables](#complextables)  
5\.  [License](#license)  
6\.  [References](#references)  

<a name="whatisperfandpubtools?"></a>

## 1\. What is PerfAndPubTools?

_PerfAndPubTools_ consists of a set of [MATLAB]/[Octave] functions for analyzing
software performance benchmark results and producing associated publication
quality materials.

<a name="benchmarkfileformat"></a>

## 2\. Benchmark file format

By default, _PerfAndPubTools_ expects individual benchmarking results to be
available as files containing the default output of [GNU time] command, for
example:

```
512.66user 2.17system 8:01.34elapsed 106%CPU (0avgtext+0avgdata 1271884maxresident)k
0inputs+2136outputs (0major+49345minor)pagefaults 0swaps
```

This preset selection can be easily modified as described in the next sections.

<a name="architectureandfunctions"></a>

## 3\. Architecture and functions

_PerfAndPubTools_ is implemented in a layered architecture with procedural
programming style, as shown in the following figure:

![arch](https://cloud.githubusercontent.com/assets/3018963/12177843/3354c2ee-b566-11e5-8d19-48f0a57d4b60.png)

Performance analysis in _PerfAndPubTools_ takes place at two levels:
*implementation* and *setup*. The *implementation* level is meant to be
associated with specific software implementations for performing a given task,
for example a particular sorting algorithm or a simulation model implemented in
a certain programming language. Within the context of each implementation, the
software can be executed under different *setups*. These can be different
computational sizes (e.g. vector lengths in a sorting algorithm context) or
distinct execution parameters (e.g. number of threads to use).

The following is a list of available functions, from lowest to highest-level of
functionality:

* [get_gtime] - Given a file containing the default output of the [GNU time]
command, this function extracts the user, system and elapsed time in seconds, as
well as the percentage of CPU usage.

* [gather_times] - Load execution times from all files in a given folder. This
function uses [get_gtime] by default, but can be configured to use another
function to load individual benchmark files with a different format.

* [perfstats] - Determine mean times and respective standard deviations of a
computational experiment using folders of files containing benchmarking results,
optionally plotting a scalability graph if different setups correspond to
different computational work sizes.

* [speedup] - Determine speedups using folders of files containing benchmarking
results, and optionally plot speedups in a bar plot.

* [times_table] - Returns a matrix with useful contents for using in tables for
publication, namely times (in seconds), absolute standard deviations (seconds),
relative standard deviations, speedups (vs the implementations specified in the
`compare` input variable).

* [times_table_f] - Print a timing table formatted in plain text or in LaTeX
(the latter requires the [siunitx], [multirow] and [booktabs] packages).

<a name="examples"></a>

## 4\. Examples

<a name="comparingsortingalgorithms"></a>

### 4.1\. Comparing sorting algorithms

In following examples _PerfAndPubTools_ is used to analyzing the performance
of several sorting algorithms implemented in C. Before proceeding:

1. Download and compile the [sorttest.c] program (instructions are available by
clicking on the link).
2. Confirm that the [GNU time] program is installed (instructions also available
in [sorttest.c]).
3. In [MATLAB]/[Octave] create a `sortfolder` variable containing the full path
of the [sorttest.c] program.

[GNU time] is invoked as `/usr/bin/time`, but this can vary for different Linux
distributions. On OSX it is invoked as `gtime`. The former invocation is used
for throughout the examples, replace it as appropriate.

Since the [GNU time] program does not seem to be available for Windows, these
examples only run unmodified on Linux and OSX. On Windows, benchmark the
[sorttest.c] program using an [alternative] approach and replace [get_gtime]
with a function which parses the produced output.

<a name="extractperformancedatafromafile"></a>

#### 4.1.1\. Extract performance data from a file

First, test that the [sorttest.c] program is working by testing the [Quicksort]
algorithm with a vector of 1,000,000 random integers:

```
$ ./sorttest quick 1000000 2362 yes
Sorting Ok!
```

The value `2362` is the seed to the random number generator, and the optional
`yes` parameter asks the program to output a message confirming if the sorting
was successful.

Now, create a benchmark file with [GNU time]:

```
$ /usr/bin/time ./sorttest quick 1000000 2362 2> out.txt 
```

The `2>` redirects the output of [GNU time] to a file called `out.txt`. This
file can be parsed with the [get_gtime] function from [MATLAB]:

```matlab
p = get_gtime('out.txt')
```

The function returns a structure with several fields:

```
p = 

       user: 0.1400
        sys: 0
    elapsed: 0.1400
        cpu: 98
```

<a name="extractexecutiontimesfromfilesinafolder"></a>

#### 4.1.2\. Extract execution times from files in a folder

The [gather_times] function extracts execution times from multiple files in a
folder. This is useful for analyzing average run times over a number of runs.
First, we need to perform these runs. From a terminal, run the following
command, which performs 10 runs of the [sorttest.c] program:

```
$ for RUN in {1..10}; do /usr/bin/time ./sorttest quick 1000000 $RUN 2> time$RUN.txt; done
```

Note that each run is performed with a different seed, so that different vectors
are sorted by [Quicksort] each turn. In [MATLAB], use the [gather_times]
function to extract execution times:

```matlab
exec_time = gather_times('Quicksort', sortfolder, 'time*.txt');
```

The first parameter of [gather_times] names the list of gathered times, and is
used as metadata by other functions. The vector of execution times is in the
`elapsed` field of the returned structure:

```matlab
exec_time.elapsed
```

The [gather_times] function uses [get_gtime] internally by default. However, 
other functions can be specified in the first line of the [gather_times]
function body, allowing _PerfAndPubTools_ to support benchmarking formats other
than the output of [GNU time]. Alternatives to [get_gtime] are only required to
return a struct with the `elapsed` field, indicating the duration (in seconds)
of a program execution.


<a name="averageexecutiontimesandstandarddeviations"></a>

#### 4.1.3\. Average execution times and standard deviations

In its most basic usage, the [perfstats] function obtains performance
statistics. In this example, average execution times and standard deviations are
obtained from the runs performed in the previous example:

```matlab
qs1M = struct('sname', 'Quicksort', 'folder', sortfolder, 'files', 'time*.txt');
[avg_time, std_time] = perfstats(0, sortfolder, {qs1M})
```

```
avg_time =

    0.1427


std_time =

    0.0326
```

The [perfstats] function uses [gather_times] internally.

<a name="comparemultiplesetupswithinthesameimplementation"></a>

#### 4.1.4\. Compare multiple setups within the same implementation

A more advanced use case for [perfstats] consists of comparing multiple setups,
associated with different computational sizes, within the same implementation
(e.g., sorting algorithm). In this example we analyze how the performance of the
[Bubble sort] algorithm varies for increasing vector sizes.

First, perform a number of runs with [sorttest.c] using [Bubble sort] for
vectors of size 10,000, 20,000 and 30,000:

```
$ for RUN in {1..10}; do for SIZE in 10000 20000 30000; do /usr/bin/time ./sorttest bubble $SIZE $RUN 2> time_bubble_${SIZE}_${RUN}.txt; done; done
```

Second, obtain the average times for the several vector sizes using [perfstats]:

```matlab
bs10k = struct('sname', 'bs10k', 'folder', sortfolder, 'files', 'time_bubble_10000_*.txt');
bs20k = struct('sname', 'bs20k', 'folder', sortfolder, 'files', 'time_bubble_20000_*.txt');
bs30k = struct('sname', 'bs30k', 'folder', sortfolder, 'files', 'time_bubble_30000_*.txt');
avg_time = perfstats(0, 'bubble', {bs10k, bs20k, bs30k})
```

```
avg_time =

    0.3220    1.3370    3.1070
```

<a name="sameaspreviouswithalinearplot"></a>

#### 4.1.5\. Same as previous, with a linear plot

The [perfstats] function can also be used to plot scalability graphs. For this
purpose, the computational size, `cize`, must be specified in each
implementation spec, and the first parameter should be a value between 1 (linear
plot) and 4 (log-log plot), as shown in the following commands:

```matlab
bs10k = struct('sname', 'bs10k', 'csize', 1e4, 'folder', sortfolder, 'files', 'time_bubble_10000_*.txt');
bs20k = struct('sname', 'bs20k', 'csize', 2e4, 'folder', sortfolder, 'files', 'time_bubble_20000_*.txt');
bs30k = struct('sname', 'bs30k', 'csize', 3e4, 'folder', sortfolder, 'files', 'time_bubble_30000_*.txt');

% The first parameter defines the plot type: 1 is a linear plot
perfstats(1, 'bubble', {bs10k, bs20k, bs30k});
```

![ex05s](https://cloud.githubusercontent.com/assets/3018963/12179235/9ed764d4-b56d-11e5-997d-d7a2fbca7ea4.png)

<a name="comparedifferentimplementations"></a>

#### 4.1.6\. Compare different implementations

Besides comparing multiple setups within the same implementation, the
[perfstats] function is also able to compare multiple setups within multiple
implementations. The requirement is that, from implementation to implementation,
the multiple setups are directly comparable, i.e., corresponding implementation
specs should have the same `sname` and `csize` parameters.

First, perform a number of runs with [sorttest.c] using [Merge sort] and
[Quicksort] for vectors of size 1e4, 1e5, 1e6 and 1e7:

```
$ for RUN in {1..10}; do for IMPL in merge quick; do for SIZE in 100000 1000000 10000000 100000000; do /usr/bin/time ./sorttest $IMPL $SIZE $RUN 2> time_${IMPL}_${SIZE}_${RUN}.txt; done; done; done
```

Second, use [perfstats] to plot the respective scalability graph:

```matlab
% Specify Merge sort implementation specs
ms1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', sortfolder, 'files', 'time_merge_100000_*.txt');
ms1e6 = struct('sname', '1e6', 'csize', 1e6, 'folder', sortfolder, 'files', 'time_merge_1000000_*.txt');
ms1e7 = struct('sname', '1e7', 'csize', 1e7, 'folder', sortfolder, 'files', 'time_merge_10000000_*.txt');
ms1e8 = struct('sname', '1e8', 'csize', 1e8, 'folder', sortfolder, 'files', 'time_merge_100000000_*.txt');
ms = {ms1e5, ms1e6, ms1e7, ms1e8};

% Specify Quicksort implementation specs
qs1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', sortfolder, 'files', 'time_quick_100000_*.txt');
qs1e6 = struct('sname', '1e6', 'csize', 1e6, 'folder', sortfolder, 'files', 'time_quick_1000000_*.txt');
qs1e7 = struct('sname', '1e7', 'csize', 1e7, 'folder', sortfolder, 'files', 'time_quick_10000000_*.txt');
qs1e8 = struct('sname', '1e8', 'csize', 1e8, 'folder', sortfolder, 'files', 'time_quick_100000000_*.txt');
qs = {qs1e5, qs1e6, qs1e7, qs1e8};

% Plot comparison with a log-log plot
perfstats(4, 'Merge sort', ms, 'Quicksort', qs);
```

![ex06s](https://cloud.githubusercontent.com/assets/3018963/12180504/d9c1cdee-b574-11e5-81c5-b34f40945a6f.png)

<a name="speedup"></a>

#### 4.1.7\. Speedup

The [speedup] function is used to obtain relative speedups between different
implementations. Using the variables defined in the previous example, lets
obtain the speedup of [Quicksort] versus [Merge sort] for different vector
sizes:

```matlab
s = speedup(0, 1, 'Merge sort', ms, 'Quicksort', qs);
```

Speedups can be obtained by getting the first element of the returned cell, i.e.
by invoking `s{1}`:

```
ans =

    1.0000    1.0000    1.0000    1.0000
    1.0500    1.7164    1.7520    1.6314
```

The second parameter indicates the reference implementation from which to 
calculate speedups. In this case, specifying 1 will return speedups against
Merge sort. The first row of the previous matrix shows the speedup of
[Merge sort] against itself, thus it is composed of ones. The second row shows
the speedup of [Quicksort] versus [Merge sort]. If the second parameter is a
vector, speedups against more than one implementation are returned.

Setting the 1st parameter to 1 will yield a bar plot displaying the relative
speedups:

```matlab
s = speedup(1, 1, 'Merge sort', ms, 'Quicksort', qs);
```

![ex07s](https://cloud.githubusercontent.com/assets/3018963/12180905/0c18a928-b577-11e5-8e93-912b534cbd61.png)

<a name="speedupformultiplealgorithmsandvectorsizes"></a>

#### 4.1.8\. Speedup for multiple algorithms and vector sizes

The [speedup] function is also able to determine relative speedups between
different implementations for multiple computational sizes. In this example we
plot the speedup of several sorting algorithms against [Bubble sort] and
[Selection sort] for vector sizes 1e5, 2e5, 3e5 and 4e5. 

First, perform a number of runs using the four sorting algorithms made available
by [sorttest.c] for the specified vector sizes:

```
$ for RUN in {1..10}; do for IMPL in bubble selection merge quick; do for SIZE in 100000 200000 300000 400000; do /usr/bin/time ./sorttest $IMPL $SIZE $RUN 2> time_${IMPL}_${SIZE}_${RUN}.txt; done; done; done
```

Then, in [MATLAB], use the [speedup] function to specify implementation specs
and plot the respective speedup graph:

```matlab
% Specify Bubble sort implementation specs
bs1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', sortfolder, 'files', 'time_bubble_100000_*.txt');
bs2e5 = struct('sname', '2e5', 'csize', 2e5, 'folder', sortfolder, 'files', 'time_bubble_200000_*.txt');
bs3e5 = struct('sname', '3e5', 'csize', 3e5, 'folder', sortfolder, 'files', 'time_bubble_300000_*.txt');
bs4e5 = struct('sname', '4e5', 'csize', 4e5, 'folder', sortfolder, 'files', 'time_bubble_400000_*.txt');
bs = {bs1e5, bs2e5, bs3e5, bs4e5};

% Specify Selection sort implementation specs
ss1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', sortfolder, 'files', 'time_selection_100000_*.txt');
ss2e5 = struct('sname', '2e5', 'csize', 2e5, 'folder', sortfolder, 'files', 'time_selection_200000_*.txt');
ss3e5 = struct('sname', '3e5', 'csize', 3e5, 'folder', sortfolder, 'files', 'time_selection_300000_*.txt');
ss4e5 = struct('sname', '4e5', 'csize', 4e5, 'folder', sortfolder, 'files', 'time_selection_400000_*.txt');
ss = {ss1e5, ss2e5, ss3e5, ss4e5};

% Specify Merge sort implementation specs
ms1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', sortfolder, 'files', 'time_merge_100000_*.txt');
ms2e5 = struct('sname', '2e5', 'csize', 2e5, 'folder', sortfolder, 'files', 'time_merge_200000_*.txt');
ms3e5 = struct('sname', '3e5', 'csize', 3e5, 'folder', sortfolder, 'files', 'time_merge_300000_*.txt');
ms4e5 = struct('sname', '4e5', 'csize', 4e5, 'folder', sortfolder, 'files', 'time_merge_400000_*.txt');
ms = {ms1e5, ms2e5, ms3e5, ms4e5};

% Specify Quicksort implementation specs
qs1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', sortfolder, 'files', 'time_quick_100000_*.txt');
qs2e5 = struct('sname', '2e5', 'csize', 2e5, 'folder', sortfolder, 'files', 'time_quick_200000_*.txt');
qs3e5 = struct('sname', '3e5', 'csize', 3e5, 'folder', sortfolder, 'files', 'time_quick_300000_*.txt');
qs4e5 = struct('sname', '4e5', 'csize', 4e5, 'folder', sortfolder, 'files', 'time_quick_400000_*.txt');
qs = {qs1e5, qs2e5, qs3e5, qs4e5};

% Plot speedup of multiple sorting algorithms against Bubble sort
% Setting the first parameter to 2 will yields a log-scale bar plot
speedup(2, 1, 'Bubble', bs, 'Selection', ss, 'Merge', ms, 'Quick', qs);
```

![ex08s_1](https://cloud.githubusercontent.com/assets/3018963/12197277/9af46e9e-b5fd-11e5-9184-07043179b17e.png)

```matlab
% Plot speedup of multiple sorting algorithms against Selection sort
speedup(1, 1, 'Selection', ss, 'Merge', ms, 'Quick', qs);
```

![ex08s_2](https://cloud.githubusercontent.com/assets/3018963/12197278/9b1263f4-b5fd-11e5-928b-377699add9f2.png)

<a name="scalabilityofthedifferentsortingalgorithmsforincreasingvectorsizes"></a>

#### 4.1.9\. Scalability of the different sorting algorithms for increasing vector sizes

Using data from the previous example, we can use [perfstats] to determine and
plot the scalability of the different sorting algorithms for increasing vector
sizes:

```matlab
p = perfstats(4, 'Bubble', bs, 'Selection', ss, 'Merge', ms, 'Quick', qs);
```

![ex09s](https://cloud.githubusercontent.com/assets/3018963/12200186/6be79b18-b615-11e5-845a-f27c6c2b7ef8.png)

The values plotted are returned in variable `p`:

```
ps =

   36.0040  144.8210  325.1730  577.8600
    9.5270   38.0500   88.5130  153.6560
    0.0200    0.0410    0.0600    0.0850
    0.0100    0.0200    0.0300    0.0510
```

<a name="produceatableinsteadofaplot"></a>

#### 4.1.10\. Produce a table instead of a plot

The [times_table] and [times_table_f] functions can be used to create
performance tables formatted in plain text or LaTeX. Using the data defined in
the previous examples, the following commands produces a plain text table
comparing the ... :

```matlab
% Put data in table format
tdata = times_table(1, 'Bubble', bs, 'Selection', ss, 'Merge', ms, 'Quick', qs);

% Print a plain text table
times_table_f(0, 'vs Bubble', tdata)
```

```
                  -----------------------------------------------
                  |                       vs Bubble             |
-----------------------------------------------------------------
| Imp.   | Set.   |   t(s)     |   std     |  std%  | x Bubble  |
-----------------------------------------------------------------
| Bubble |    1e5 |         36 |     0.887 |   2.46 |         1 |
|        |    2e5 |        145 |      2.92 |   2.02 |         1 |
|        |    3e5 |        325 |      6.19 |   1.90 |         1 |
|        |    4e5 |        578 |      6.38 |   1.10 |         1 |
-----------------------------------------------------------------
| Select |    1e5 |       9.53 |     0.069 |   0.72 |      3.78 |
|        |    2e5 |         38 |     0.283 |   0.74 |      3.81 |
|        |    3e5 |       88.5 |       3.7 |   4.18 |      3.67 |
|        |    4e5 |        154 |      3.06 |   1.99 |      3.76 |
-----------------------------------------------------------------
|  Merge |    1e5 |       0.02 |  3.66e-18 |   0.00 |   1.8e+03 |
|        |    2e5 |      0.041 |   0.00316 |   7.71 |  3.53e+03 |
|        |    3e5 |       0.06 |  1.46e-17 |   0.00 |  5.42e+03 |
|        |    4e5 |      0.085 |    0.0127 |  14.93 |   6.8e+03 |
-----------------------------------------------------------------
|  Quick |    1e5 |       0.01 |  1.83e-18 |   0.00 |   3.6e+03 |
|        |    2e5 |       0.02 |  3.66e-18 |   0.00 |  7.24e+03 |
|        |    3e5 |       0.03 |  7.31e-18 |   0.00 |  1.08e+04 |
|        |    4e5 |      0.051 |   0.00316 |   6.20 |  1.13e+04 |
-----------------------------------------------------------------
```

In order to produce the equivalent LaTeX table, we set the first parameter to 1
instead of 0:

```matlab
% Print a Latex table
times_table_f(1, 'vs Bubble', tdata)
```

![ex10s](https://cloud.githubusercontent.com/assets/3018963/12204259/f166cd94-b62a-11e5-88ee-ec8ac6bb24c0.png)


<a name="replicatingresultsofanexistingpublication"></a>

### 4.2\. Replicating results of an existing publication

The following examples use the dataset available at 
[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.34049.svg)](http://dx.doi.org/10.5281/zenodo.34049).
Unpack the datasets to any folder and put the complete path to this folder in 
variable `datafolder`, e.g.:

```matlab
datafolder = 'path/to/datasets';
```

These datasets correspond to the results presented in reference [\[1\]][ref1].

<a name="extractperformancedatafromafile-1"></a>

#### 4.2.1\. Extract performance data from a file

The [get_gtime] function extracts performance data from one file containing the
default output of [GNU time] command. For example:

```matlab
p = get_gtime([datafolder '/times/NL/time100v1r1.txt'])
```

The function returns a structure with several fields:

```
p = 

       user: 17.6800
        sys: 0.3200
    elapsed: 16.5900
        cpu: 108
```

<a name="extractexecutiontimesfromfilesinafolder-1"></a>

#### 4.2.2\. Extract execution times from files in a folder

The [gather_times] function extracts execution times from multiple files in a
folder, as shown in the following command:

```matlab
exec_time = gather_times('NetLogo', [datafolder '/times/NL'], 'time100v1*.txt');
```

The vector of execution times is in the `elapsed` field of the returned
structure:

```matlab
exec_time.elapsed
```

The [gather_times] function uses [get_gtime] internally by default. However, 
other functions can be specified in the first line of the [gather_times]
function body, allowing _PerfAndPubTools_ to support benchmarking formats other
than the output of [GNU time]. Alternatives to [get_gtime] are only required to
return a struct with the `elapsed` field, indicating the duration (in seconds)
of a program execution.

<a name="averageexecutiontimesandstandarddeviations-1"></a>

#### 4.2.3\. Average execution times and standard deviations

In its most basic usage, the [perfstats] function obtains performance
statistics. In this example, average execution times and standard deviations are
obtained from 10 replications of the Java implementation of [PPHPC]
(single-thread, ST) for size 800, parameter set 2:

```matlab
st800v2 = struct('sname', '800v1', 'folder', [datafolder '/times/ST'], 'files', 't*800v2*.txt');
[avg_time, std_time] = perfstats(0, 'ST', {st800v2})
```

```
avg_time =

  699.5920


std_time =

    3.6676
```

The [perfstats] function uses [gather_times] internally.

<a name="comparemultiplesetupswithinthesameimplementation-1"></a>

#### 4.2.4\. Compare multiple setups within the same implementation

A more advanced use case for [perfstats] consists of comparing multiple setups,
associated with different computational sizes, within the same implementation.
For example, considering the Java ST implementation of the [PPHPC] model, lets
analyze how its performance varies for increasing model sizes:

```matlab
st100v2 = struct('sname', '100v2', 'folder', [datafolder '/times/ST'], 'files', 't*100v2*.txt');
st200v2 = struct('sname', '200v2', 'folder', [datafolder '/times/ST'], 'files', 't*200v2*.txt');
st400v2 = struct('sname', '400v2', 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
st800v2 = struct('sname', '800v2', 'folder', [datafolder '/times/ST'], 'files', 't*800v2*.txt');
st1600v2 = struct('sname', '1600v2', 'folder', [datafolder '/times/ST'], 'files', 't*1600v2*.txt');
avg_time = perfstats(0, 'ST', {st100v2, st200v2, st400v2, st800v2, st1600v2})
```

```
avg_time =

   1.0e+03 *

    0.0053    0.0361    0.1589    0.6996    2.9572
```

<a name="sameaspreviouswithalog-logplot"></a>

#### 4.2.5\. Same as previous, with a log-log plot

The [perfstats] function can also be used to plot scalability graphs. For this
purpose, the computational size, `cize`, must be specified in each
implementation spec, and the first parameter should be a value between 1 (linear
plot) and 4 (log-log plot), as shown in the following commands:

```matlab
st100v2 = struct('sname', '100v2', 'csize', 100, 'folder', [datafolder '/times/ST'], 'files', 't*100v2*.txt');
st200v2 = struct('sname', '200v2', 'csize', 200, 'folder', [datafolder '/times/ST'], 'files', 't*200v2*.txt');
st400v2 = struct('sname', '400v2', 'csize', 400, 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
st800v2 = struct('sname', '800v2', 'csize', 800, 'folder', [datafolder '/times/ST'], 'files', 't*800v2*.txt');
st1600v2 = struct('sname', '1600v2', 'csize', 1600, 'folder', [datafolder '/times/ST'], 'files', 't*1600v2*.txt');

% The first parameter defines the plot type: 4 is a log-log plot
perfstats(4, 'ST', {st100v2, st200v2, st400v2, st800v2, st1600v2});
```

![ex05](https://cloud.githubusercontent.com/assets/3018963/11914709/b521c1c4-a67e-11e5-9e20-f05bfbe6921d.png)

<a name="comparedifferentimplementations-1"></a>

#### 4.2.6\. Compare different implementations

Besides comparing multiple setups within the same implementation, the
[perfstats] function is also able to compare multiple setups within multiple
implementations. The requirement is that, from implementation to implementation,
the multiple setups are directly comparable, i.e., corresponding implementation
specs should have the same `sname` and `csize` parameters, as shown in the
following commands, where the NetLogo (NL) and Java single-thread (ST) [PPHPC]
implementations are compared for sizes 100 to 1600, parameter set 1:

```matlab
% Specify NetLogo implementation specs
nl100v1 = struct('sname', '100v1', 'csize', 100, 'folder', [datafolder '/times/NL'], 'files', 't*100v1*.txt');
nl200v1 = struct('sname', '200v1', 'csize', 200, 'folder', [datafolder '/times/NL'], 'files', 't*200v1*.txt');
nl400v1 = struct('sname', '400v1', 'csize', 400, 'folder', [datafolder '/times/NL'], 'files', 't*400v1*.txt');
nl800v1 = struct('sname', '800v1', 'csize', 800, 'folder', [datafolder '/times/NL'], 'files', 't*800v1*.txt');
nl1600v1 = struct('sname', '1600v1', 'csize', 1600, 'folder', [datafolder '/times/NL'], 'files', 't*1600v1*.txt');
nlv1 = {nl100v1, nl200v1, nl400v1, nl800v1, nl1600v1};

% Specify Java ST implementation specs
st100v1 = struct('sname', '100v1', 'csize', 100, 'folder', [datafolder '/times/ST'], 'files', 't*100v1*.txt');
st200v1 = struct('sname', '200v1', 'csize', 200, 'folder', [datafolder '/times/ST'], 'files', 't*200v1*.txt');
st400v1 = struct('sname', '400v1', 'csize', 400, 'folder', [datafolder '/times/ST'], 'files', 't*400v1*.txt');
st800v1 = struct('sname', '800v1', 'csize', 800, 'folder', [datafolder '/times/ST'], 'files', 't*800v1*.txt');
st1600v1 = struct('sname', '1600v1', 'csize', 1600, 'folder', [datafolder '/times/ST'], 'files', 't*1600v1*.txt');
stv1 = {st100v1, st200v1, st400v1, st800v1, st1600v1};

% Plot comparison
perfstats(4, 'NL', nlv1, 'ST', stv1);
```

![ex06](https://cloud.githubusercontent.com/assets/3018963/11914710/b524dd5a-a67e-11e5-82d0-8f2ef0401e30.png)

<a name="speedup-1"></a>

#### 4.2.7\. Speedup

The [speedup] function is used to obtain relative speedups between different
implementations. Using the variables defined in the previous example, lets
obtain the speedup of the Java ST version versus the NetLogo implementation for
different model sizes:

```matlab
s = speedup(0, 1, 'NL', nlv1, 'ST', stv1);
```

Speedups can be obtained by getting the first element of the returned cell, i.e.
by invoking `s{1}`:

```
ans =

    1.0000    1.0000    1.0000    1.0000    1.0000
    5.8513    8.2370    5.7070    5.4285    5.4331
```

The second parameter indicates the reference implementation from which to 
calculate speedups. In this case, specifying 1 will return speedups against the
NetLogo implementation. The first row of the previous matrix shows the speedup
of the NetLogo implementation against itself, thus it is composed of ones. The
second row shows the speedup of the Java ST implementation versus the NetLogo
implementation. If the second parameter is a vector, speedups against more than
one implementation are returned.

Setting the 1st parameter to 1 will yield a bar plot displaying the relative
speedups:

```matlab
speedup(1, 1, 'NL', nlv1, 'ST', stv1);
```

![ex07](https://cloud.githubusercontent.com/assets/3018963/11914711/b5259966-a67e-11e5-9faf-32770a2f080e.png)

<a name="speedupformultipleparallelimplementationsandsizes"></a>

#### 4.2.8\. Speedup for multiple parallel implementations and sizes

The [speedup] function is also able to determine relative speedups between
different implementations for multiple computational sizes. In this example we
plot the speedup of several [PPHPC] parallel Java implementations against the
NetLogo and Java single-thread implementations for multiple sizes. This example
uses the variables defined in example 6, and the plotted results are equivalent
to figures 4a and 4b of reference [\[1\]][ref1]:

```matlab
% Specify Java EQ implementation specs (runs with 12 threads)
eq100v1t12 = struct('sname', '100v1', 'csize', 100, 'folder', [datafolder '/times/EQ'], 'files', 't*100v1*t12r*.txt');
eq200v1t12 = struct('sname', '200v1', 'csize', 200, 'folder', [datafolder '/times/EQ'], 'files', 't*200v1*t12r*.txt');
eq400v1t12 = struct('sname', '400v1', 'csize', 400, 'folder', [datafolder '/times/EQ'], 'files', 't*400v1*t12r*.txt');
eq800v1t12 = struct('sname', '800v1', 'csize', 800, 'folder', [datafolder '/times/EQ'], 'files', 't*800v1*t12r*.txt');
eq1600v1t12 = struct('sname', '1600v1', 'csize', 1600, 'folder', [datafolder '/times/EQ'], 'files', 't*1600v1*t12r*.txt');
eqv1t12 = {eq100v1t12, eq200v1t12, eq400v1t12, eq800v1t12, eq1600v1t12};

% Specify Java EX implementation specs (runs with 12 threads)
ex100v1t12 = struct('sname', '100v1', 'csize', 100, 'folder', [datafolder '/times/EX'], 'files', 't*100v1*t12r*.txt');
ex200v1t12 = struct('sname', '200v1', 'csize', 200, 'folder', [datafolder '/times/EX'], 'files', 't*200v1*t12r*.txt');
ex400v1t12 = struct('sname', '400v1', 'csize', 400, 'folder', [datafolder '/times/EX'], 'files', 't*400v1*t12r*.txt');
ex800v1t12 = struct('sname', '800v1', 'csize', 800, 'folder', [datafolder '/times/EX'], 'files', 't*800v1*t12r*.txt');
ex1600v1t12 = struct('sname', '1600v1', 'csize', 1600, 'folder', [datafolder '/times/EX'], 'files', 't*1600v1*t12r*.txt');
exv1t12 = {ex100v1t12, ex200v1t12, ex400v1t12, ex800v1t12, ex1600v1t12};

% Specify Java ER implementation specs (runs with 12 threads)
er100v1t12 = struct('sname', '100v1', 'csize', 100, 'folder', [datafolder '/times/ER'], 'files', 't*100v1*t12r*.txt');
er200v1t12 = struct('sname', '200v1', 'csize', 200, 'folder', [datafolder '/times/ER'], 'files', 't*200v1*t12r*.txt');
er400v1t12 = struct('sname', '400v1', 'csize', 400, 'folder', [datafolder '/times/ER'], 'files', 't*400v1*t12r*.txt');
er800v1t12 = struct('sname', '800v1', 'csize', 800, 'folder', [datafolder '/times/ER'], 'files', 't*800v1*t12r*.txt');
er1600v1t12 = struct('sname', '1600v1', 'csize', 1600, 'folder', [datafolder '/times/ER'], 'files', 't*1600v1*t12r*.txt');
erv1t12 = {er100v1t12, er200v1t12, er400v1t12, er800v1t12, er1600v1t12};

% Specify Java OD implementation specs (runs with 12 threads, b = 500)
od100v1t12 = struct('sname', '100v1', 'csize', 100, 'folder', [datafolder '/times/OD'], 'files', 't*100v1*b500t12r*.txt');
od200v1t12 = struct('sname', '200v1', 'csize', 200, 'folder', [datafolder '/times/OD'], 'files', 't*200v1*b500t12r*.txt');
od400v1t12 = struct('sname', '400v1', 'csize', 400, 'folder', [datafolder '/times/OD'], 'files', 't*400v1*b500t12r*.txt');
od800v1t12 = struct('sname', '800v1', 'csize', 800, 'folder', [datafolder '/times/OD'], 'files', 't*800v1*b500t12r*.txt');
od1600v1t12 = struct('sname', '1600v1', 'csize', 1600, 'folder', [datafolder '/times/OD'], 'files', 't*1600v1*b500t12r*.txt');
odv1t12 = {od100v1t12, od200v1t12, od400v1t12, od800v1t12, od1600v1t12};

% Plot speedup of multiple parallel implementations against NetLogo implementation
% This plot is figure 4a of the specified manuscript
speedup(1, 1, 'NL', nlv1, 'ST', stv1, 'EQ', eqv1t12, 'EX', exv1t12, 'ER', erv1t12, 'OD', odv1t12);
```

![ex08_1](https://cloud.githubusercontent.com/assets/3018963/11914712/b52c33b6-a67e-11e5-8ea6-489f025329f6.png)

```matlab
% Plot speedup of multiple parallel implementations against Java ST implementation
% This plot is figure 4b of the specified manuscript
speedup(1, 1, 'ST', stv1, 'EQ', eqv1t12, 'EX', exv1t12, 'ER', erv1t12, 'OD', odv1t12);
```

![ex08_2](https://cloud.githubusercontent.com/assets/3018963/11914714/b52fdcbe-a67e-11e5-8da2-7aae819e1337.png)

<a name="scalabilityofthedifferentimplementationsforincreasingmodelsizes"></a>

#### 4.2.9\. Scalability of the different implementations for increasing model sizes

In a slightly more complex scenario than the one described in example 6, here
we use the [perfstats] function to plot the scalability of the different [PPHPC]
implementations for increasing model sizes. Using the variables defined in the
previous examples, the following command plot the equivalent to figure 5a of
reference [\[1\]][ref1]:

```matlab
perfstats(4, 'NL', nlv1, 'ST', stv1, 'EQ', eqv1t12, 'EX', exv1t12, 'ER', erv1t12, 'OD', odv1t12);
```

![ex09](https://cloud.githubusercontent.com/assets/3018963/11914713/b52f195a-a67e-11e5-9a69-761526351f6d.png)

<a name="scalabilityofparallelimplementationsforincreasingnumberofthreads"></a>

#### 4.2.10\. Scalability of parallel implementations for increasing number of threads

The 'computational size', i.e. the `csize` field, defined in the implementation
specs passed to the [perfstats] function can be used in alternative contexts. In
this example, we use the `csize` field to specify the number of threads used to
perform a set of simulation runs, i.e., replications. The following commands
will plot the scalability of the several [PPHPC] parallel implementations for
increasing number of threads. The plotted results are equivalent to figure 6d of
reference [\[1\]][ref1]:

```matlab
% Specify ST implementation specs, note that the data is always the same
% so in practice the scalability will be constant for ST. However, this is a
% nice trick to have a comparison standard in the plot.
st400v2t1 = struct('sname', '400v2', 'csize', 1, 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
st400v2t2 = struct('sname', '400v2', 'csize', 2, 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
st400v2t4 = struct('sname', '400v2', 'csize', 4, 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
st400v2t6 = struct('sname', '400v2', 'csize', 6, 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
st400v2t8 = struct('sname', '400v2', 'csize', 8, 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
st400v2t12 = struct('sname', '400v2', 'csize', 12, 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
st400v2t16 = struct('sname', '400v2', 'csize', 16, 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
st400v2t24 = struct('sname', '400v2', 'csize', 24, 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
stv2 = {st400v2t1, st400v2t2, st400v2t4, st400v2t6, st400v2t8, st400v2t12, st400v2t16, st400v2t24};

% Specify the EQ implementation specs for increasing number of threads
eq400v2t1 = struct('sname', '400v2', 'csize', 1, 'folder', [datafolder '/times/EQ'], 'files', 't*400v2*t1r*.txt');
eq400v2t2 = struct('sname', '400v2', 'csize', 2, 'folder', [datafolder '/times/EQ'], 'files', 't*400v2*t2r*.txt');
eq400v2t4 = struct('sname', '400v2', 'csize', 4, 'folder', [datafolder '/times/EQ'], 'files', 't*400v2*t4r*.txt');
eq400v2t6 = struct('sname', '400v2', 'csize', 6, 'folder', [datafolder '/times/EQ'], 'files', 't*400v2*t6r*.txt');
eq400v2t8 = struct('sname', '400v2', 'csize', 8, 'folder', [datafolder '/times/EQ'], 'files', 't*400v2*t8r*.txt');
eq400v2t12 = struct('sname', '400v2', 'csize', 12, 'folder', [datafolder '/times/EQ'], 'files', 't*400v2*t12r*.txt');
eq400v2t16 = struct('sname', '400v2', 'csize', 16, 'folder', [datafolder '/times/EQ'], 'files', 't*400v2*t16r*.txt');
eq400v2t24 = struct('sname', '400v2', 'csize', 24, 'folder', [datafolder '/times/EQ'], 'files', 't*400v2*t24r*.txt');
eqv2 = {eq400v2t1, eq400v2t2, eq400v2t4, eq400v2t6, eq400v2t8, eq400v2t12, eq400v2t16, eq400v2t24};

% Specify the EX implementation specs for increasing number of threads
ex400v2t1 = struct('sname', '400v2', 'csize', 1, 'folder', [datafolder '/times/EX'], 'files', 't*400v2*t1r*.txt');
ex400v2t2 = struct('sname', '400v2', 'csize', 2, 'folder', [datafolder '/times/EX'], 'files', 't*400v2*t2r*.txt');
ex400v2t4 = struct('sname', '400v2', 'csize', 4, 'folder', [datafolder '/times/EX'], 'files', 't*400v2*t4r*.txt');
ex400v2t6 = struct('sname', '400v2', 'csize', 6, 'folder', [datafolder '/times/EX'], 'files', 't*400v2*t6r*.txt');
ex400v2t8 = struct('sname', '400v2', 'csize', 8, 'folder', [datafolder '/times/EX'], 'files', 't*400v2*t8r*.txt');
ex400v2t12 = struct('sname', '400v2', 'csize', 12, 'folder', [datafolder '/times/EX'], 'files', 't*400v2*t12r*.txt');
ex400v2t16 = struct('sname', '400v2', 'csize', 16, 'folder', [datafolder '/times/EX'], 'files', 't*400v2*t16r*.txt');
ex400v2t24 = struct('sname', '400v2', 'csize', 24, 'folder', [datafolder '/times/EX'], 'files', 't*400v2*t24r*.txt');
exv2 = {ex400v2t1, ex400v2t2, ex400v2t4, ex400v2t6, ex400v2t8, ex400v2t12, ex400v2t16, ex400v2t24};

% Specify the ER implementation specs for increasing number of threads
er400v2t1 = struct('sname', '400v2', 'csize', 1, 'folder', [datafolder '/times/ER'], 'files', 't*400v2*t1r*.txt');
er400v2t2 = struct('sname', '400v2', 'csize', 2, 'folder', [datafolder '/times/ER'], 'files', 't*400v2*t2r*.txt');
er400v2t4 = struct('sname', '400v2', 'csize', 4, 'folder', [datafolder '/times/ER'], 'files', 't*400v2*t4r*.txt');
er400v2t6 = struct('sname', '400v2', 'csize', 6, 'folder', [datafolder '/times/ER'], 'files', 't*400v2*t6r*.txt');
er400v2t8 = struct('sname', '400v2', 'csize', 8, 'folder', [datafolder '/times/ER'], 'files', 't*400v2*t8r*.txt');
er400v2t12 = struct('sname', '400v2', 'csize', 12, 'folder', [datafolder '/times/ER'], 'files', 't*400v2*t12r*.txt');
er400v2t16 = struct('sname', '400v2', 'csize', 16, 'folder', [datafolder '/times/ER'], 'files', 't*400v2*t16r*.txt');
er400v2t24 = struct('sname', '400v2', 'csize', 24, 'folder', [datafolder '/times/ER'], 'files', 't*400v2*t24r*.txt');
erv2 = {er400v2t1, er400v2t2, er400v2t4, er400v2t6, er400v2t8, er400v2t12, er400v2t16, er400v2t24};

% Specify the OD implementation specs for increasing number of threads (b = 500)
od400v2t1 = struct('sname', '400v2', 'csize', 1, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b500t1r*.txt');
od400v2t2 = struct('sname', '400v2', 'csize', 2, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b500t2r*.txt');
od400v2t4 = struct('sname', '400v2', 'csize', 4, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b500t4r*.txt');
od400v2t6 = struct('sname', '400v2', 'csize', 6, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b500t6r*.txt');
od400v2t8 = struct('sname', '400v2', 'csize', 8, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b500t8r*.txt');
od400v2t12 = struct('sname', '400v2', 'csize', 12, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b500t12r*.txt');
od400v2t16 = struct('sname', '400v2', 'csize', 16, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b500t16r*.txt');
od400v2t24 = struct('sname', '400v2', 'csize', 24, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b500t24r*.txt');
odv2 = {od400v2t1, od400v2t2, od400v2t4, od400v2t6, od400v2t8, od400v2t12, od400v2t16, od400v2t24};

% Use a linear plot (first parameter = 1)
perfstats(1, 'ST', stv2, 'EQ', eqv2, 'EX', exv2, 'ER', erv2, 'OD', odv2);
```

![ex10](https://cloud.githubusercontent.com/assets/3018963/11914715/b53d4b74-a67e-11e5-85e3-4cd1349152a1.png)

<a name="performanceofodstrategyfordifferentvaluesof_b_"></a>

#### 4.2.11\. Performance of OD strategy for different values of _b_

In yet another possible use of the [perfstats] function, in this example we use
the `csize` field to specify the value of the _b_ parameter of the [PPHPC] model
Java OD variant. This allows us to analyze the performance of the OD
parallelization strategy for different values of _b_. The plot created by the
following commands is equivalent to figure 7b of reference [\[1\]][ref1]:

```matlab
% Specify the OD implementation specs for size 100 and increasing values of b
od100v2b20 = struct('sname', 'b=20', 'csize', 20, 'folder', [datafolder '/times/OD'], 'files', 't*100v2*b20t12r*.txt');
od100v2b50 = struct('sname', 'b=50', 'csize', 50, 'folder', [datafolder '/times/OD'], 'files', 't*100v2*b50t12r*.txt');
od100v2b100 = struct('sname', 'b=100', 'csize', 100, 'folder', [datafolder '/times/OD'], 'files', 't*100v2*b100t12r*.txt');
od100v2b200 = struct('sname', 'b=200', 'csize', 200, 'folder', [datafolder '/times/OD'], 'files', 't*100v2*b200t12r*.txt');
od100v2b500 = struct('sname', 'b=500', 'csize', 500, 'folder', [datafolder '/times/OD'], 'files', 't*100v2*b500t12r*.txt');
od100v2b1000 = struct('sname', 'b=1000', 'csize', 1000, 'folder', [datafolder '/times/OD'], 'files', 't*100v2*b1000t12r*.txt');
od100v2b2000 = struct('sname', 'b=2000', 'csize', 2000, 'folder', [datafolder '/times/OD'], 'files', 't*100v2*b2000t12r*.txt');
od100v2b5000 = struct('sname', 'b=5000', 'csize', 5000, 'folder', [datafolder '/times/OD'], 'files', 't*100v2*b5000t12r*.txt');
od100v2 = {od100v2b20, od100v2b50, od100v2b100, od100v2b200, od100v2b500, od100v2b1000, od100v2b2000, od100v2b5000};

% Specify the OD implementation specs for size 200 and increasing values of b
od200v2b20 = struct('sname', 'b=20', 'csize', 20, 'folder', [datafolder '/times/OD'], 'files', 't*200v2*b20t12r*.txt');
od200v2b50 = struct('sname', 'b=50', 'csize', 50, 'folder', [datafolder '/times/OD'], 'files', 't*200v2*b50t12r*.txt');
od200v2b100 = struct('sname', 'b=100', 'csize', 100, 'folder', [datafolder '/times/OD'], 'files', 't*200v2*b100t12r*.txt');
od200v2b200 = struct('sname', 'b=200', 'csize', 200, 'folder', [datafolder '/times/OD'], 'files', 't*200v2*b200t12r*.txt');
od200v2b500 = struct('sname', 'b=500', 'csize', 500, 'folder', [datafolder '/times/OD'], 'files', 't*200v2*b500t12r*.txt');
od200v2b1000 = struct('sname', 'b=1000', 'csize', 1000, 'folder', [datafolder '/times/OD'], 'files', 't*200v2*b1000t12r*.txt');
od200v2b2000 = struct('sname', 'b=2000', 'csize', 2000, 'folder', [datafolder '/times/OD'], 'files', 't*200v2*b2000t12r*.txt');
od200v2b5000 = struct('sname', 'b=5000', 'csize', 5000, 'folder', [datafolder '/times/OD'], 'files', 't*200v2*b5000t12r*.txt');
od200v2 = {od200v2b20, od200v2b50, od200v2b100, od200v2b200, od200v2b500, od200v2b1000, od200v2b2000, od200v2b5000};

% Specify the OD implementation specs for size 400 and increasing values of b
od400v2b20 = struct('sname', 'b=20', 'csize', 20, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b20t12r*.txt');
od400v2b50 = struct('sname', 'b=50', 'csize', 50, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b50t12r*.txt');
od400v2b100 = struct('sname', 'b=100', 'csize', 100, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b100t12r*.txt');
od400v2b200 = struct('sname', 'b=200', 'csize', 200, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b200t12r*.txt');
od400v2b500 = struct('sname', 'b=500', 'csize', 500, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b500t12r*.txt');
od400v2b1000 = struct('sname', 'b=1000', 'csize', 1000, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b1000t12r*.txt');
od400v2b2000 = struct('sname', 'b=2000', 'csize', 2000, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b2000t12r*.txt');
od400v2b5000 = struct('sname', 'b=5000', 'csize', 5000, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b5000t12r*.txt');
od400v2 = {od400v2b20, od400v2b50, od400v2b100, od400v2b200, od400v2b500, od400v2b1000, od400v2b2000, od400v2b5000};

% Specify the OD implementation specs for size 800 and increasing values of b
od800v2b20 = struct('sname', 'b=20', 'csize', 20, 'folder', [datafolder '/times/OD'], 'files', 't*800v2*b20t12r*.txt');
od800v2b50 = struct('sname', 'b=50', 'csize', 50, 'folder', [datafolder '/times/OD'], 'files', 't*800v2*b50t12r*.txt');
od800v2b100 = struct('sname', 'b=100', 'csize', 100, 'folder', [datafolder '/times/OD'], 'files', 't*800v2*b100t12r*.txt');
od800v2b200 = struct('sname', 'b=200', 'csize', 200, 'folder', [datafolder '/times/OD'], 'files', 't*800v2*b200t12r*.txt');
od800v2b500 = struct('sname', 'b=500', 'csize', 500, 'folder', [datafolder '/times/OD'], 'files', 't*800v2*b500t12r*.txt');
od800v2b1000 = struct('sname', 'b=1000', 'csize', 1000, 'folder', [datafolder '/times/OD'], 'files', 't*800v2*b1000t12r*.txt');
od800v2b2000 = struct('sname', 'b=2000', 'csize', 2000, 'folder', [datafolder '/times/OD'], 'files', 't*800v2*b2000t12r*.txt');
od800v2b5000 = struct('sname', 'b=5000', 'csize', 5000, 'folder', [datafolder '/times/OD'], 'files', 't*800v2*b5000t12r*.txt');
od800v2 = {od800v2b20, od800v2b50, od800v2b100, od800v2b200, od800v2b500, od800v2b1000, od800v2b2000, od800v2b5000};

% Specify the OD implementation specs for size 1600 and increasing values of b
od1600v2b20 = struct('sname', 'b=20', 'csize', 20, 'folder', [datafolder '/times/OD'], 'files', 't*1600v2*b20t12r*.txt');
od1600v2b50 = struct('sname', 'b=50', 'csize', 50, 'folder', [datafolder '/times/OD'], 'files', 't*1600v2*b50t12r*.txt');
od1600v2b100 = struct('sname', 'b=100', 'csize', 100, 'folder', [datafolder '/times/OD'], 'files', 't*1600v2*b100t12r*.txt');
od1600v2b200 = struct('sname', 'b=200', 'csize', 200, 'folder', [datafolder '/times/OD'], 'files', 't*1600v2*b200t12r*.txt');
od1600v2b500 = struct('sname', 'b=500', 'csize', 500, 'folder', [datafolder '/times/OD'], 'files', 't*1600v2*b500t12r*.txt');
od1600v2b1000 = struct('sname', 'b=1000', 'csize', 1000, 'folder', [datafolder '/times/OD'], 'files', 't*1600v2*b1000t12r*.txt');
od1600v2b2000 = struct('sname', 'b=2000', 'csize', 2000, 'folder', [datafolder '/times/OD'], 'files', 't*1600v2*b2000t12r*.txt');
od1600v2b5000 = struct('sname', 'b=5000', 'csize', 5000, 'folder', [datafolder '/times/OD'], 'files', 't*1600v2*b5000t12r*.txt');
od1600v2 = {od1600v2b20, od1600v2b50, od1600v2b100, od1600v2b200, od1600v2b500, od1600v2b1000, od1600v2b2000, od1600v2b5000};

% Show plot
perfstats(4, '100', od100v2, '200', od200v2, '400', od400v2, '800', od800v2, '1600', od1600v2);
```

![ex11](https://cloud.githubusercontent.com/assets/3018963/11914716/b543721a-a67e-11e5-9a34-cfd1eac7a3ba.png)

<a name="sameasexample6butshowatableinsteadofaplot"></a>

#### 4.2.12\. Same as example 6, but show a table instead of a plot

The [times_table] and [times_table_f] functions can be used to create
performance tables formatted in plain text or LaTeX. Using the data defined in
example 6, the following commands produces a plain text table comparing the
NetLogo (NL) and Java single-thread (ST) [PPHPC] implementations for sizes 100
to 1600, parameter set 1:

```matlab
% Put data in table format
tdata = times_table(1, 'NL', nlv1, 'ST', stv1);

% Print a plain text table
times_table_f(0, 'NL vs ST', tdata)
```

```
                ------------------------------------------
                |                     NL vs ST           |
----------------------------------------------------------
| Imp. | Set.   |   t(s)    |   std   |  std%  | x   NL  |
----------------------------------------------------------
|   NL |  100v1 |     15.86 |    0.36 |   2.26 |    1.00 |
|      |  200v1 |    100.25 |    1.25 |   1.25 |    1.00 |
|      |  400v1 |    481.48 |    6.02 |   1.25 |    1.00 |
|      |  800v1 |   2077.10 |    9.75 |   0.47 |    1.00 |
|      | 1600v1 |   9115.80 |   94.14 |   1.03 |    1.00 |
----------------------------------------------------------
|   ST |  100v1 |      2.71 |    0.02 |   0.82 |    5.85 |
|      |  200v1 |     12.17 |    0.22 |   1.80 |    8.24 |
|      |  400v1 |     84.37 |    2.83 |   3.35 |    5.71 |
|      |  800v1 |    382.63 |    5.04 |   1.32 |    5.43 |
|      | 1600v1 |   1677.82 |   78.41 |   4.67 |    5.43 |
----------------------------------------------------------
```

In order to produce the equivalent LaTeX table, we set the first parameter to 1
instead of 0:

```matlab
% Print a Latex table
times_table_f(1, 'NL vs ST', tdata)
```

![ex12](https://cloud.githubusercontent.com/assets/3018963/11914717/b543e4ca-a67e-11e5-9d57-6348aabb91ad.png)

<a name="complextables"></a>

#### 4.2.13\. Complex tables

The [times_table] and [times_table_f] functions are capable of producing more
complex tables. In this example, we show how to reproduce table 7 of reference
[\[1\]][ref1], containing times and speedups for different model
implementations, different sizes and different parameter sets, showing speedups
of all implementations versus the NetLogo and Java ST versions.

The first step consists of specifying the implementation specs:

```matlab
% %%%%%%%%%%%%%%%%%%%%%%%%% %
% Specs for parameter set 1 %
% %%%%%%%%%%%%%%%%%%%%%%%%% %

% Specify NetLogo implementation specs, parameter set 1
nl100v1 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/NL'], 'files', 't*100v1*.txt');
nl200v1 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/NL'], 'files', 't*200v1*.txt');
nl400v1 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/NL'], 'files', 't*400v1*.txt');
nl800v1 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/NL'], 'files', 't*800v1*.txt');
nl1600v1 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/NL'], 'files', 't*1600v1*.txt');
nlv1 = {nl100v1, nl200v1, nl400v1, nl800v1, nl1600v1};

% Specify Java ST implementation specs, parameter set 1
st100v1 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/ST'], 'files', 't*100v1*.txt');
st200v1 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/ST'], 'files', 't*200v1*.txt');
st400v1 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/ST'], 'files', 't*400v1*.txt');
st800v1 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/ST'], 'files', 't*800v1*.txt');
st1600v1 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/ST'], 'files', 't*1600v1*.txt');
stv1 = {st100v1, st200v1, st400v1, st800v1, st1600v1};

% Specify Java EQ implementation specs (runs with 12 threads), parameter set 1
eq100v1t12 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/EQ'], 'files', 't*100v1*t12r*.txt');
eq200v1t12 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/EQ'], 'files', 't*200v1*t12r*.txt');
eq400v1t12 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/EQ'], 'files', 't*400v1*t12r*.txt');
eq800v1t12 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/EQ'], 'files', 't*800v1*t12r*.txt');
eq1600v1t12 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/EQ'], 'files', 't*1600v1*t12r*.txt');
eqv1t12 = {eq100v1t12, eq200v1t12, eq400v1t12, eq800v1t12, eq1600v1t12};

% Specify Java EX implementation specs (runs with 12 threads), parameter set 1
ex100v1t12 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/EX'], 'files', 't*100v1*t12r*.txt');
ex200v1t12 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/EX'], 'files', 't*200v1*t12r*.txt');
ex400v1t12 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/EX'], 'files', 't*400v1*t12r*.txt');
ex800v1t12 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/EX'], 'files', 't*800v1*t12r*.txt');
ex1600v1t12 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/EX'], 'files', 't*1600v1*t12r*.txt');
exv1t12 = {ex100v1t12, ex200v1t12, ex400v1t12, ex800v1t12, ex1600v1t12};

% Specify Java ER implementation specs (runs with 12 threads), parameter set 1
er100v1t12 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/ER'], 'files', 't*100v1*t12r*.txt');
er200v1t12 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/ER'], 'files', 't*200v1*t12r*.txt');
er400v1t12 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/ER'], 'files', 't*400v1*t12r*.txt');
er800v1t12 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/ER'], 'files', 't*800v1*t12r*.txt');
er1600v1t12 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/ER'], 'files', 't*1600v1*t12r*.txt');
erv1t12 = {er100v1t12, er200v1t12, er400v1t12, er800v1t12, er1600v1t12};

% Specify Java OD implementation specs (runs with 12 threads, b = 500), parameter set 1
od100v1t12 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/OD'], 'files', 't*100v1*b500t12r*.txt');
od200v1t12 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/OD'], 'files', 't*200v1*b500t12r*.txt');
od400v1t12 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/OD'], 'files', 't*400v1*b500t12r*.txt');
od800v1t12 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/OD'], 'files', 't*800v1*b500t12r*.txt');
od1600v1t12 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/OD'], 'files', 't*1600v1*b500t12r*.txt');
odv1t12 = {od100v1t12, od200v1t12, od400v1t12, od800v1t12, od1600v1t12};

% %%%%%%%%%%%%%%%%%%%%%%%%% %
% Specs for parameter set 2 %
% %%%%%%%%%%%%%%%%%%%%%%%%% %

% Specify NetLogo implementation specs, parameter set 2
nl100v2 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/NL'], 'files', 't*100v2*.txt');
nl200v2 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/NL'], 'files', 't*200v2*.txt');
nl400v2 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/NL'], 'files', 't*400v2*.txt');
nl800v2 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/NL'], 'files', 't*800v2*.txt');
nl1600v2 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/NL'], 'files', 't*1600v2*.txt');
nlv2 = {nl100v2, nl200v2, nl400v2, nl800v2, nl1600v2};

% Specify Java ST implementation specs, parameter set 2
st100v2 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/ST'], 'files', 't*100v2*.txt');
st200v2 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/ST'], 'files', 't*200v2*.txt');
st400v2 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
st800v2 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/ST'], 'files', 't*800v2*.txt');
st1600v2 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/ST'], 'files', 't*1600v2*.txt');
stv2 = {st100v2, st200v2, st400v2, st800v2, st1600v2};

% Specify Java EQ implementation specs (runs with 12 threads), parameter set 2
eq100v2t12 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/EQ'], 'files', 't*100v2*t12r*.txt');
eq200v2t12 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/EQ'], 'files', 't*200v2*t12r*.txt');
eq400v2t12 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/EQ'], 'files', 't*400v2*t12r*.txt');
eq800v2t12 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/EQ'], 'files', 't*800v2*t12r*.txt');
eq1600v2t12 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/EQ'], 'files', 't*1600v2*t12r*.txt');
eqv2t12 = {eq100v2t12, eq200v2t12, eq400v2t12, eq800v2t12, eq1600v2t12};

% Specify Java EX implementation specs (runs with 12 threads), parameter set 2
ex100v2t12 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/EX'], 'files', 't*100v2*t12r*.txt');
ex200v2t12 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/EX'], 'files', 't*200v2*t12r*.txt');
ex400v2t12 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/EX'], 'files', 't*400v2*t12r*.txt');
ex800v2t12 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/EX'], 'files', 't*800v2*t12r*.txt');
ex1600v2t12 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/EX'], 'files', 't*1600v2*t12r*.txt');
exv2t12 = {ex100v2t12, ex200v2t12, ex400v2t12, ex800v2t12, ex1600v2t12};

% Specify Java ER implementation specs (runs with 12 threads), parameter set 2
er100v2t12 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/ER'], 'files', 't*100v2*t12r*.txt');
er200v2t12 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/ER'], 'files', 't*200v2*t12r*.txt');
er400v2t12 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/ER'], 'files', 't*400v2*t12r*.txt');
er800v2t12 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/ER'], 'files', 't*800v2*t12r*.txt');
er1600v2t12 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/ER'], 'files', 't*1600v2*t12r*.txt');
erv2t12 = {er100v2t12, er200v2t12, er400v2t12, er800v2t12, er1600v2t12};

% Specify Java OD implementation specs (runs with 12 threads, b = 500), parameter set 2
od100v2t12 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/OD'], 'files', 't*100v2*b500t12r*.txt');
od200v2t12 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/OD'], 'files', 't*200v2*b500t12r*.txt');
od400v2t12 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b500t12r*.txt');
od800v2t12 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/OD'], 'files', 't*800v2*b500t12r*.txt');
od1600v2t12 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/OD'], 'files', 't*1600v2*b500t12r*.txt');
odv2t12 = {od100v2t12, od200v2t12, od400v2t12, od800v2t12, od1600v2t12};
```

After the implementation specs are specified, we create two intermediate table:

```matlab
% %%%%%%%%%%%%%%%%%%% %
% Intermediate tables %
% %%%%%%%%%%%%%%%%%%% %

% Parameter set 1
data_v1 = times_table([1 2], 'NL', nlv1, 'ST', stv1, 'EQ', eqv1t12, 'EX', exv1t12, 'ER', erv1t12, 'OD', odv1t12);

% Parameter set 2
data_v2 = times_table([1 2], 'NL', nlv2, 'ST', stv2, 'EQ', eqv2t12, 'EX', exv2t12, 'ER', erv2t12, 'OD', odv2t12);
```

We first print a plain text table, to check how the information is organized:

```matlab
% %%%%%%%%%%%% %
% Print tables %
% %%%%%%%%%%%% %

% Plain text table
times_table_f(0, 'Param. set 1', data_v1, 'Param. set 2', data_v2)
```

```
                -------------------------------------------------------------------------------------------------------
                |                 Param. set 1                     |                 Param. set 2                     |
-----------------------------------------------------------------------------------------------------------------------
| Imp. | Set.   |   t(s)    |   std   |  std%  | x   NL  | x   ST  |   t(s)    |   std   |  std%  | x   NL  | x   ST  |
-----------------------------------------------------------------------------------------------------------------------
|   NL |    100 |     15.86 |    0.36 |   2.26 |    1.00 |    0.17 |     32.18 |    0.69 |   2.13 |    1.00 |    0.17 |
|      |    200 |    100.25 |    1.25 |   1.25 |    1.00 |    0.12 |    245.38 |    1.50 |   0.61 |    1.00 |    0.15 |
|      |    400 |    481.48 |    6.02 |   1.25 |    1.00 |    0.18 |   1074.21 |    3.63 |   0.34 |    1.00 |    0.15 |
|      |    800 |   2077.10 |    9.75 |   0.47 |    1.00 |    0.18 |   4536.90 |   23.18 |   0.51 |    1.00 |    0.15 |
|      |   1600 |   9115.80 |   94.14 |   1.03 |    1.00 |    0.18 |  19559.30 |   90.86 |   0.46 |    1.00 |    0.15 |
-----------------------------------------------------------------------------------------------------------------------
|   ST |    100 |      2.71 |    0.02 |   0.82 |    5.85 |    1.00 |      5.34 |    0.05 |   0.96 |    6.03 |    1.00 |
|      |    200 |     12.17 |    0.22 |   1.80 |    8.24 |    1.00 |     36.12 |    0.18 |   0.49 |    6.79 |    1.00 |
|      |    400 |     84.37 |    2.83 |   3.35 |    5.71 |    1.00 |    158.95 |    0.47 |   0.30 |    6.76 |    1.00 |
|      |    800 |    382.63 |    5.04 |   1.32 |    5.43 |    1.00 |    699.59 |    3.67 |   0.52 |    6.49 |    1.00 |
|      |   1600 |   1677.82 |   78.41 |   4.67 |    5.43 |    1.00 |   2957.20 |  122.60 |   4.15 |    6.61 |    1.00 |
-----------------------------------------------------------------------------------------------------------------------
|   EQ |    100 |      1.55 |    0.03 |   1.62 |   10.24 |    1.75 |      1.87 |    0.03 |   1.53 |   17.21 |    2.85 |
|      |    200 |      2.81 |    0.11 |   4.01 |   35.61 |    4.32 |      7.08 |    0.13 |   1.78 |   34.64 |    5.10 |
|      |    400 |     19.46 |    0.21 |   1.10 |   24.74 |    4.34 |     31.17 |    0.21 |   0.66 |   34.46 |    5.10 |
|      |    800 |     86.08 |    4.26 |   4.95 |   24.13 |    4.45 |    125.27 |    4.15 |   3.32 |   36.22 |    5.58 |
|      |   1600 |    279.23 |    4.04 |   1.45 |   32.65 |    6.01 |    487.34 |    8.48 |   1.74 |   40.14 |    6.07 |
-----------------------------------------------------------------------------------------------------------------------
|   EX |    100 |      1.53 |    0.03 |   1.90 |   10.39 |    1.78 |      2.14 |    0.06 |   2.75 |   15.06 |    2.50 |
|      |    200 |      2.91 |    0.11 |   3.69 |   34.40 |    4.18 |      8.08 |    0.14 |   1.74 |   30.37 |    4.47 |
|      |    400 |     19.56 |    0.30 |   1.54 |   24.62 |    4.31 |     34.22 |    0.53 |   1.54 |   31.40 |    4.65 |
|      |    800 |     86.49 |    5.46 |   6.31 |   24.01 |    4.42 |    138.99 |    5.96 |   4.29 |   32.64 |    5.03 |
|      |   1600 |    281.57 |    5.49 |   1.95 |   32.37 |    5.96 |    531.96 |    5.24 |   0.99 |   36.77 |    5.56 |
-----------------------------------------------------------------------------------------------------------------------
|   ER |    100 |      7.29 |    0.33 |   4.46 |    2.18 |    0.37 |      8.39 |    0.15 |   1.76 |    3.83 |    0.64 |
|      |    200 |     16.44 |    0.77 |   4.68 |    6.10 |    0.74 |     17.91 |    0.25 |   1.41 |   13.70 |    2.02 |
|      |    400 |     37.16 |    0.20 |   0.55 |   12.96 |    2.27 |     45.91 |    0.28 |   0.62 |   23.40 |    3.46 |
|      |    800 |    111.45 |    3.37 |   3.02 |   18.64 |    3.43 |    159.25 |    3.21 |   2.02 |   28.49 |    4.39 |
|      |   1600 |    331.77 |    3.50 |   1.06 |   27.48 |    5.06 |    553.44 |    8.03 |   1.45 |   35.34 |    5.34 |
-----------------------------------------------------------------------------------------------------------------------
|   OD |    100 |      1.36 |    0.02 |   1.16 |   11.70 |    2.00 |      2.00 |    0.03 |   1.66 |   16.13 |    2.68 |
|      |    200 |      2.68 |    0.07 |   2.61 |   37.42 |    4.54 |      6.64 |    0.11 |   1.64 |   36.95 |    5.44 |
|      |    400 |     19.19 |    0.20 |   1.04 |   25.09 |    4.40 |     29.09 |    0.12 |   0.42 |   36.93 |    5.46 |
|      |    800 |     82.94 |    2.27 |   2.73 |   25.04 |    4.61 |    117.62 |    3.00 |   2.55 |   38.57 |    5.95 |
|      |   1600 |    292.16 |    8.51 |   2.91 |   31.20 |    5.74 |    478.83 |    9.32 |   1.95 |   40.85 |    6.18 |
-----------------------------------------------------------------------------------------------------------------------
```

Finally, we produce the LaTeX table, as shown in reference [\[1\]][ref1]:

```matlab
% Latex table
times_table_f(1, 'Param. set 1', data_v1, 'Param. set 2', data_v2)
```

![ex13](https://cloud.githubusercontent.com/assets/3018963/11914718/b54b70be-a67e-11e5-8ed0-5d3c99d2e93f.png)

<a name="license"></a>

## 5\. License

[MIT License](LICENSE)

<a name="references"></a>

## 6\. References

<a name="ref1"></a>

[\[1\]][ref1] Fachada N, Lopes VV, Martins RC, Rosa AC. (2016) Parallelization
Strategies for Spatial Agent-Based Models. *International Journal of Parallel
Programming*. https://doi.org/10.1007/s10766-015-0399-9 (arXiv version available
at http://arxiv.org/abs/1507.04047)

[ref1]: #ref1
[Matlab]: http://www.mathworks.com/products/matlab/
[Octave]: https://gnu.org/software/octave/
[sorttest.c]: https://github.com/fakenmc/sorttest_c
[alternative]: http://stackoverflow.com/questions/673523/how-to-measure-execution-time-of-command-in-windows-command-line
[Bubble sort]: https://en.wikipedia.org/wiki/Bubble_sort
[Selection sort]: https://en.wikipedia.org/wiki/Selection_sort
[Merge sort]: https://en.wikipedia.org/wiki/Merge_sort
[Quicksort]: https://en.wikipedia.org/wiki/Quicksort
[PPHPC]: https://github.com/fakenmc/pphpc
[GNU time]: https://www.gnu.org/software/time/
[siunitx]: https://www.ctan.org/pkg/siunitx
[multirow]: https://www.ctan.org/pkg/multirow
[booktabs]: https://www.ctan.org/pkg/booktabs
[get_gtime]: get_gtime.m
[gather_times]: gather_times.m
[perfstats]: perfstats.m
[speedup]: speedup.m
[times_table]: times_table.m
[times_table_f]: times_table_f.m

