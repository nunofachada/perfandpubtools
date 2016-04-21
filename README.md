PerfAndPubTools
===============

1\.  [What is PerfAndPubTools?](#whatisperfandpubtools?)  
2\.  [Benchmark file format](#benchmarkfileformat)  
3\.  [Architecture and functions](#architectureandfunctions)  
4\.  [Examples](#examples)  
4.1\.  [Performance analysis of sorting algorithms](#performanceanalysisofsortingalgorithms)  
4.1.1\.  [Extract performance data from a file](#extractperformancedatafromafile)  
4.1.2\.  [Extract execution times from files in a folder](#extractexecutiontimesfromfilesinafolder)  
4.1.3\.  [Average execution times and standard deviations](#averageexecutiontimesandstandarddeviations)  
4.1.4\.  [Compare multiple setups within the same implementation](#comparemultiplesetupswithinthesameimplementation)  
4.1.5\.  [Same as previous, with a linear plot](#sameaspreviouswithalinearplot)  
4.1.6\.  [Compare different implementations](#comparedifferentimplementations)  
4.1.7\.  [Speedup](#speedup)  
4.1.8\.  [Speedup for multiple algorithms and vector sizes](#speedupformultiplealgorithmsandvectorsizes)  
4.1.9\.  [Custom speedup plots](#customspeedupplots)  
4.1.10\.  [Scalability of the different sorting algorithms for increasing vector sizes](#scalabilityofthedifferentsortingalgorithmsforincreasingvectorsizes)  
4.1.11\.  [Custom scalability plots](#customscalabilityplots)  
4.1.12\.  [Produce a table instead of a plot](#produceatableinsteadofaplot)  
4.2\.  [Performance analysis of a simulation model](#performanceanalysisofasimulationmodel)  
4.2.1\.  [Implementations and setups of the PPHPC agent-based model](#implementationsandsetupsofthepphpcagent-basedmodel)  
4.2.2\.  [Extract performance data from a file](#extractperformancedatafromafile-1)  
4.2.3\.  [Extract execution times from files in a folder](#extractexecutiontimesfromfilesinafolder-1)  
4.2.4\.  [Average execution times and standard deviations](#averageexecutiontimesandstandarddeviations-1)  
4.2.5\.  [Compare multiple setups within the same implementation](#comparemultiplesetupswithinthesameimplementation-1)  
4.2.6\.  [Same as previous, with a log-log plot](#sameaspreviouswithalog-logplot)  
4.2.7\.  [Compare different implementations](#comparedifferentimplementations-1)  
4.2.8\.  [Speedup](#speedup-1)  
4.2.9\.  [Speedup for multiple parallel implementations and sizes](#speedupformultipleparallelimplementationsandsizes)  
4.2.10\.  [Scalability of the different implementations for increasing model sizes](#scalabilityofthedifferentimplementationsforincreasingmodelsizes)  
4.2.11\.  [Scalability of parallel implementations for increasing number of threads](#scalabilityofparallelimplementationsforincreasingnumberofthreads)  
4.2.12\.  [Performance of OD strategy for different values of _b_](#performanceofodstrategyfordifferentvaluesof_b_)  
4.2.13\.  [Custom performance plot](#customperformanceplot)  
4.2.14\.  [Show a table instead of a plot](#showatableinsteadofaplot)  
4.2.15\.  [Complex tables](#complextables)  
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

_PerfAndPubTools_ is implemented in a layered architecture using a procedural
programming approach, as shown in the following figure:

![arch](https://cloud.githubusercontent.com/assets/3018963/12206544/74c5ac38-b639-11e5-87c2-fc65e6bf8875.png)

Performance analysis in _PerfAndPubTools_ takes place at two levels:
*implementation* and *setup*. The *implementation* level is meant to be
associated with specific software implementations for performing a given task,
for example a particular sorting algorithm or a simulation model realized in
a certain programming language. Within the context of each implementation, the
software can be executed under different *setups*. These can be different
computational sizes (e.g. vector lengths in a sorting algorithm) or distinct
execution parameters (e.g. number of threads used).

_PerfAndPubTools_ is bundled with the following functions, from lowest to
highest-level of functionality:

* [get_gtime] - Given a file containing the default output of the [GNU time]
command, this function extracts the user, system and elapsed times in seconds,
as well as the percentage of CPU usage.

* [gather_times] - Loads execution times from files in a given folder. This
function uses [get_gtime] by default, but can be configured to use another
function to load individual benchmark files with a different format.

* [perfstats] - Determines mean times and respective standard deviations of a
computational experiment using folders of files containing benchmarking results,
optionally plotting a scalability graph if different setups correspond to
different computational work sizes.

* [speedup] - Determines the average, maximum and minimum speedups against one
or more reference *implementations* across a number of *setups*. Can optionally
generate a bar plot displaying the various speedups.

* [times_table] - Returns a matrix with useful contents for using in tables for
publication, namely times (in seconds), absolute standard deviations (seconds),
relative standard deviations, speedups (vs the specified implementations).

* [times_table_f] - Returns a table with performance analysis results formatted
in plain text or in LaTeX (the latter requires the [siunitx], [multirow] and
[booktabs] packages).

Although the [perfstats] and [speedup] functions optionally create plots, these
are mainly intended to provide visual feedback on the performance analysis being
undertaken. Those needing more control over the final figures can customize the
generated plots via the returned figure handles or create custom plots using the
data provided by [perfstats] and [speedup]. Either way, [MATLAB]/[Octave] plots
can be used directly in publications, or converted to LaTeX using the excellent
[matlab2tikz] script, as will be shown in some of the examples.

<a name="examples"></a>

## 4\. Examples

Examples are organized into two sections:

1. [Performance analysis of sorting algorithms](#exsortalgs)
2. [Performance analysis of a simulation model](#exsimmods)

Examples in the first section demonstrate the complete process of benchmarking a
number of sorting algorithms with the [GNU time] command and then analyzing
results with _PerfAndPubTools_. Since the [GNU time] command is not available on
Windows, the data produced by the benchmarks is [included][sort_data] in the
package.

Examples in the second section focus on showing how _PerfAndPubTools_ was used
to analyze performance data of multiple implementations of a
[simulation model][PPHPC], replicating results presented in a peer-reviewed
article [\[1\]](#ref1). The initial benchmarking steps are skipped in these
examples, but the produced data and the scripts used to generate it are also
made [available][pphpc_data].

<a name="exsortalgs"></a>

<a name="performanceanalysisofsortingalgorithms"></a>

### 4.1\. Performance analysis of sorting algorithms

In following examples, we use _PerfAndPubTools_ to analyze the performance of
several sorting algorithms implemented in C. Perform the following steps before
proceeding:

1. Download and compile the [sorttest.c] program (instructions are available in
the linked page).
2. Confirm that the [GNU time] program is installed (instructions also available
in [sorttest.c]).
3. In [MATLAB]/[Octave] create a `sortfolder` variable containing the full path
of the [sorttest.c] program, for example `sortfolder = '/home/user/sort'`
(Unix/Linux) or `sortfolder = 'C:\Users\UserName\Documents\sort'` (Windows).

[GNU time] is usually invoked as `/usr/bin/time`, but this can vary for
different Linux distributions. On OSX it is invoked as `gtime`. The usual Linux
invocation is used for throughout the examples, replace it as appropriate.

Since the [GNU time] program does not seem to be available for Windows, these
examples only run unmodified on Linux and OSX. On Windows, benchmark the
[sorttest.c] program using an [alternative] approach and replace [get_gtime]
with a function which parses the produced output. Otherwise, skip the actual
benchmarking steps within the examples, and use the benchmarking data bundled
with _PerfAndPubTools_ in the [data][sort_data] folder.

<a name="extractperformancedatafromafile"></a>

#### 4.1.1\. Extract performance data from a file

First, check that the [sorttest.c] program is working by testing the [Quicksort]
algorithm with a vector of 1,000,000 random integers:

```
$ ./sorttest quick 1000000 2362 yes
Sorting Ok!
```

The value `2362` is the seed for the random number generator, and the optional
`yes` parameter asks the program to output a message confirming if the sorting
was successful.

Now, create a benchmark file with [GNU time]:

```
$ /usr/bin/time ./sorttest quick 1000000 2362 2> out.txt 
```

The `2>` part redirects the output of [GNU time] to a file called `out.txt`.
This file can be parsed with the [get_gtime] function from [MATLAB] or [Octave]:

```matlab
p = get_gtime('out.txt')
```

The function returns a structure with several fields:

```
p = 

       user: 0.2000
        sys: 0
    elapsed: 0.2000
        cpu: 99
```

<a name="extractexecutiontimesfromfilesinafolder"></a>

#### 4.1.2\. Extract execution times from files in a folder

The [gather_times] function extracts execution times from multiple files in a
folder. This is useful for analyzing average run times over a number of runs.
First, we need to perform these runs. From a terminal, run the following
command, which performs 10 runs of the [sorttest.c] program:

```
$ for RUN in {1..10}; do /usr/bin/time ./sorttest quick 1000000 $RUN 2> time_quick_1000000_$RUN.txt; done
```

Note that each run is performed with a different seed, so that different vectors
are sorted by [Quicksort] each turn. In [MATLAB] or [Octave], use the
[gather_times] function to extract execution times:

```matlab
exec_time = gather_times('Quicksort', sortfolder, 'time_quick_1000000_*.txt');
```

The first parameter names the list of gathered times, and is used as metadata by
other functions. The second parameter specifies the folder where the [GNU time]
output files are located. The vector of execution times is in the `elapsed`
field of the returned structure:

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
qs1M = struct('sname', 'Quicksort', 'folder', sortfolder, 'files', 'time_quick_1000000_*.txt');
[avg_time, std_time] = perfstats(0, 'QuickSort', {qs1M})
```

```
avg_time =

    0.1340


std_time =

    0.0052
```

The `qs1M` variable specifies a *setup*. A setup is defined by the following
fields: a) `sname`, the name of the setup; b) `folder`, the folder where to load
benchmark files from; c) `files`, the specific files to load (using wildcards);
and, d) `csize`, an optional computational size for plotting purposes. 


<a name="comparemultiplesetupswithinthesameimplementation"></a>

#### 4.1.4\. Compare multiple setups within the same implementation

A more advanced use case for [perfstats] consists of comparing multiple setups
associated with different computational sizes within the same implementation
(e.g., the same sorting algorithm). A set of multiple setups is designated as an
*implementation spec*, the basic object type accepted by the [perfstats],
[speedup] and [times_table] functions. An implementation spec defines one or
more *setups* for a single *implementation*.

In this example we analyze how the performance of the [Bubble sort] algorithm
varies for increasing vector sizes. First, perform a number of runs with
[sorttest.c] using [Bubble sort] for vectors of size 10,000, 20,000 and 30,000:

```
$ for RUN in {1..10}; do for SIZE in 10000 20000 30000; do /usr/bin/time ./sorttest bubble $SIZE $RUN 2> time_bubble_${SIZE}_${RUN}.txt; done; done
```

Second, obtain the average times for the several vector sizes using [perfstats]:

```matlab
% Specify the setups
bs10k = struct('sname', 'bs10k', 'folder', sortfolder, 'files', 'time_bubble_10000_*.txt');
bs20k = struct('sname', 'bs20k', 'folder', sortfolder, 'files', 'time_bubble_20000_*.txt');
bs30k = struct('sname', 'bs30k', 'folder', sortfolder, 'files', 'time_bubble_30000_*.txt');

% Specify the implementation spec
bs =  {bs10k, bs20k, bs30k};

% Determine average time for each setup
avg_time = perfstats(0, 'bubble', {bs10k, bs20k, bs30k})
```

```
avg_time =

    0.3220    1.3370    3.1070
```

<a name="sameaspreviouswithalinearplot"></a>

#### 4.1.5\. Same as previous, with a linear plot

The [perfstats] function can also generate scalability plots. For this purpose,
the computational size, `csize`, must be specified in each setup, and the first
parameter should be a value between 1 (linear plot) and 4 (log-log plot), as
shown in the following commands:

```matlab
% Specify the setups
bs10k = struct('sname', 'bs10k', 'csize', 1e4, 'folder', sortfolder, 'files', 'time_bubble_10000_*.txt');
bs20k = struct('sname', 'bs20k', 'csize', 2e4, 'folder', sortfolder, 'files', 'time_bubble_20000_*.txt');
bs30k = struct('sname', 'bs30k', 'csize', 3e4, 'folder', sortfolder, 'files', 'time_bubble_30000_*.txt');

% Specify the implementation spec
bs =  {bs10k, bs20k, bs30k};

% The first parameter defines the plot type: 1 is a linear plot
perfstats(1, 'bubble', bs);
```

![ex4 1 5_1](https://cloud.githubusercontent.com/assets/3018963/14692286/0d3a86ae-074e-11e6-95c7-270c35ce04de.png)

Error bars, showing the standard deviation, can be activated by passing a
negative value as the first parameter:

```matlab
% The first parameter defines the plot type: -1 is a linear plot
% with error bars showing the standard deviation
perfstats(-1, 'bubble', bs);
```

![ex4 1 5_2](https://cloud.githubusercontent.com/assets/3018963/14692287/0d40bbbe-074e-11e6-8d2c-c7d245b7cbd1.png)

<a name="comparedifferentimplementations"></a>

#### 4.1.6\. Compare different implementations

Besides comparing multiple setups within the same implementation, the
[perfstats] function is also able to compare multiple setups from multiple
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

![ex4 1 6_1](https://cloud.githubusercontent.com/assets/3018963/14692288/0d42faaa-074e-11e6-8eea-94dde29d3e5d.png)

Like in the previous example, error bars are displayed by passing a negative
value as the first parameter to [perfstats]:

```matlab
% Plot comparison with a log-log plot with error bars
perfstats(-4, 'Merge sort', ms, 'Quicksort', qs);
```

![ex4 1 6_2](https://cloud.githubusercontent.com/assets/3018963/14692289/0d47a0c8-074e-11e6-928e-6f5fd8ed6528.png)

<a name="speedup"></a>

#### 4.1.7\. Speedup

The [speedup] function is used to obtain relative speedups between different
implementations. Using the variables defined in the previous example, the
following instruction obtains the average, maximum and minimum speedups of
[Quicksort] versus [Merge sort] for different vector sizes:

```matlab
[s_avg, s_max, s_min] = speedup(0, 1, 'Merge sort', ms, 'Quicksort', qs);
```

Speedups can be obtained by getting the first element of the returned cell, i.e.
by invoking `s_avg{1}`:

```
ans =

    1.0000    1.0000    1.0000    1.0000
    2.0000    1.7164    1.7520    1.6314
```

The second parameter indicates the reference implementation from which to 
calculate speedups. In this case, specifying 1 will return speedups against
Merge sort. The first row of the previous matrix shows the speedup of
[Merge sort] against itself, thus it is composed of ones. The second row shows
the speedup of [Quicksort] versus [Merge sort]. If the second parameter is a
vector, speedups against more than one implementation are returned.

Setting the first parameter to 1 will yield a bar plot displaying the average
speedups:

```matlab
speedup(1, 1, 'Merge sort', ms, 'Quicksort', qs);
```

![ex4 1 7_1](https://cloud.githubusercontent.com/assets/3018963/14688435/6bf1c108-073a-11e6-8cc8-258ea48f04a5.png)

Speedup bar plots also support error bars, but in this case error bars show the
maximum and minimum speedups. Error bars are activated by passing a negative
number as the first argument to [speedup]:

```matlab
speedup(-1, 1, 'Merge sort', ms, 'Quicksort', qs);
```

![ex4 1 7_2](https://cloud.githubusercontent.com/assets/3018963/14688434/6bf16118-073a-11e6-8266-f0355fd3cb1f.png)

<a name="speedupformultiplealgorithmsandvectorsizes"></a>

#### 4.1.8\. Speedup for multiple algorithms and vector sizes

The [speedup] function is also able to determine relative speedups between
different implementations for multiple computational sizes. In this example we
plot the average speedup of several sorting algorithms against [Bubble sort] and
[Selection sort] for vector sizes 1e5, 2e5, 3e5 and 4e5. 

First, perform a number of runs using the four sorting algorithms made available
by [sorttest.c] for the specified vector sizes:

```
$ for RUN in {1..10}; do for IMPL in bubble selection merge quick; do for SIZE in 100000 200000 300000 400000; do /usr/bin/time ./sorttest $IMPL $SIZE $RUN 2> time_${IMPL}_${SIZE}_${RUN}.txt; done; done; done
```

Then, in [MATLAB] or [Octave], specify the implementation specs for each sorting
algorithm and setup combination, and use the [speedup] function to  plot the
respective speedup plot:

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

% Place legend in a better position
legend(gca, 'Location', 'NorthWest');
```

![ex4 1 8_1](https://cloud.githubusercontent.com/assets/3018963/14703285/15d2f75c-07a7-11e6-8f0f-bd5d83bb5774.png)

```matlab
% Plot speedup of multiple sorting algorithms against Selection sort
speedup(1, 1, 'Selection', ss, 'Merge', ms, 'Quick', qs);

% Place legend in a better position
legend(gca, 'Location', 'NorthWest');
```

![ex4 1 8_2](https://cloud.githubusercontent.com/assets/3018963/14703318/399654a4-07a7-11e6-8828-a84ce171ff5a.png)


If we require error bars, the first parameter should be a negative value:

```matlab
% Same plot with error bars
speedup(-1, 1, 'Selection', ss, 'Merge', ms, 'Quick', qs);

% Place legend in a better position
legnd = legend(gca, 'show');
set(legnd, 'Location', 'NorthWest');
```

![ex4 1 8_3](https://cloud.githubusercontent.com/assets/3018963/14703592/82136b9e-07a8-11e6-85fe-778b190c4cde.png)

Generated plots can be customized using the [MATLAB] or [Octave] GUI, or
programmatically. The following commands change some of the default properties
of the previous plot:

```matlab
% Get the current axes children objects
ch = get(gca, 'Children')

% Set the color of the '1e5' bars to white
set(ch(8), 'FaceColor', 'w')

% Change the default labels
ylabel('Average speedup over Selection sort')
xlabel('Algorithms');
```

![ex4 1 8_4](https://cloud.githubusercontent.com/assets/3018963/14703632/c29a1dfc-07a8-11e6-8876-b8b2b9578dc6.png)

<a name="customspeedupplots"></a>

#### 4.1.9\. Custom speedup plots

For more control over the speedup plots, it may preferable to use the data
provided by [speedup] and build the plots from the beginning. Continuing from
the previous example, the following sequence of instructions generates a
customized plot showing the speedup of the sorting algorithms against
[Bubble sort]:

```matlab
% Obtain speedup of multiple sorting algorithms against Bubble sort, no plot
s = speedup(0, 1, 'Bubble', bs, 'Selection', ss, 'Merge', ms, 'Quick', qs);

% Generate basic speedup bar plot (first element of s cell array and rows 2 to 4,
% to avoid displaying the speedup of Bubble sort against itself)
h = bar(s{1}(2:4, :), 'basevalue', 1);

% Customize plot
set(h(1), 'FaceColor', [0 0 0])
set(h(2), 'FaceColor', [0.33 0.33 0.33])
set(h(3), 'FaceColor', [0.66 0.66 0.66])
set(h(4), 'FaceColor', [1 1 1])
set(gca, 'YScale', 'log')
grid on
grid minor
legend({'1 \times 10^5', '2 \times 10^5', '3 \times 10^5', '4 \times 10^5'}, 'Location', 'NorthWest')
set(gca, 'XTickLabel', {'Selection', 'Merge', 'Quick'})
ylabel('Speedup')
```

![ex4 1 9_1](https://cloud.githubusercontent.com/assets/3018963/14691633/367ade1e-074a-11e6-9935-40f5e9f49763.png)

Although the figure seems appropriate for publication purposes, it can be
converted to native LaTeX via the [matlab2tikz] script:

```matlab
cleanfigure();
matlab2tikz('standalone', true, 'filename', 'image.tex');
```

Compiling the `image.tex` file with a LaTeX engine yields the following figure:

![ex4 1 9_2](https://cloud.githubusercontent.com/assets/3018963/14691634/3681a91a-074a-11e6-818c-498c68d2f8f0.png)

<a name="scalabilityofthedifferentsortingalgorithmsforincreasingvectorsizes"></a>

#### 4.1.10\. Scalability of the different sorting algorithms for increasing vector sizes

Continuing from the previous example, we can use [perfstats] to determine and
plot the scalability of the different sorting algorithms for increasing vector
sizes:

```matlab
p = perfstats(3, 'Bubble', bs, 'Selection', ss, 'Merge', ms, 'Quick', qs);
```

![ex4 1 10](https://cloud.githubusercontent.com/assets/3018963/14692331/502d8646-074e-11e6-9cc9-fb7fe8fd9cb5.png)

The values plotted are returned in variable `p`:

```
p =

   36.0040  144.8210  325.1730  577.8600
    9.5270   38.0500   88.5130  153.6560
    0.0200    0.0410    0.0600    0.0850
    0.0100    0.0200    0.0300    0.0510
```

<a name="customscalabilityplots"></a>

#### 4.1.11\. Custom scalability plots

In a similar fashion to the speedup plots, finer control over the scalability
plots is possible by directly using the data provided by [perfstats]. The
following sequence of instructions customizes the figure in the previous
example:

```matlab
% Plot data from perfstats in y-axis in log-scale
h = semilogy(p', 'Color', 'k');

% Set different markers for the various lines
set(h(1), 'Marker', 'd', 'MarkerFaceColor', 'w');
set(h(2), 'Marker', 'o', 'MarkerFaceColor', 'k');
set(h(3), 'Marker', '*');
set(h(4), 'Marker', 's', 'MarkerFaceColor', [0.8 0.8 0.8]);

% Make space for legend and add legend
ylim([1e-2 3e3]);
legend({'Bubble', 'Selection', 'Merge', 'Quick'}, 'Location', 'NorthWest');

% Set horizontal ticks
set(gca, 'XTick', 1:4);
set(gca, 'XTickLabel', {'1e5', '2e5', '3e5', '4e5'});

% Add a grid
grid on;

% Add x and y labels
xlabel('Vector size');
ylabel('Time (s)');
```

![ex4 1 11_1](https://cloud.githubusercontent.com/assets/3018963/14691914/c9e8deca-074b-11e6-8386-d15ca2f5f773.png)

We can further improve the figure, and convert it to LaTeX with [matlab2tikz]:

```matlab
% Minor grids in LaTeX image are not great, so remove them
grid minor;

% Set horizontal ticks, LaTeX-style
set(gca, 'XTickLabel', {'$1 \times 10^5$', '$2 \times 10^5$', '$3 \times 10^5$', '$4 \times 10^5$'});

% Export figure to LaTeX
cleanfigure();
matlab2tikz('standalone', true, 'filename', 'image.tex');
```

Compiling the `image.tex` file with a LaTeX engine yields the following figure:

![ex4 1 11_2](https://cloud.githubusercontent.com/assets/3018963/14691915/ca03003e-074b-11e6-85fd-155e7cf2314a.png)

<a name="produceatableinsteadofaplot"></a>

#### 4.1.12\. Produce a table instead of a plot

The [times_table] and [times_table_f] functions can be used to create
performance tables formatted in plain text or LaTeX. Using the data defined in
the previous examples, the following commands produce a plain text table
comparing the performance of the different sorting algorithms:

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

In order to obtain the equivalent LaTeX table, we set the first parameter to 1
instead of 0:

```matlab
% Print a Latex table
times_table_f(1, 'vs Bubble', tdata)
```

![ex4 1 12](https://cloud.githubusercontent.com/assets/3018963/14691916/ca160698-074b-11e6-9598-9bd2ce6f6a7e.png)

<a name="exsimmods"></a>

<a name="performanceanalysisofasimulationmodel"></a>

### 4.2\. Performance analysis of a simulation model

The examples in this section use the following [dataset][pphpc_data]:

* [![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.34049.svg)](http://dx.doi.org/10.5281/zenodo.34049)

Unpack the [dataset][pphpc_data] to any folder and specify the complete path to
this folder in variable `datafolder`, e.g.:

```matlab
datafolder = 'path/to/dataset';
```

This [dataset][pphpc_data] corresponds to the results presented in reference
[\[1\]](#ref1), which compares the performance of several implementations of the
[PPHPC] agent-based model. Among several aspects of _PerfAndPubTools_, the
following examples show how to replicate these results.

<a name="implementationsandsetupsofthepphpcagent-basedmodel"></a>

#### 4.2.1\. Implementations and setups of the PPHPC agent-based model

While most details about [PPHPC] and its various implementations are not
important for this discussion, is convenient to know which implementations and
setups were experimented with in reference [\[1\]](#ref1). A total of six
implementations of the [PPHPC] model were compared:

Implementation | Description
---------------|------------
NL             | [NetLogo] implementation (no parallelization).
ST             | Java single-thread implementation (no parallelization).
EQ             | Java parallel implementation (equal work).
EX             | Java parallel implementation (equal work, reproducible).
ER             | Java parallel implementation (row-wise synchronization).
OD             | Java parallel implementation (on-demand work).

A number of setups are directly related with the model itself, namely **model
size** and **parameter set**. Concerning model size, [PPHPC] was benchmarked
with sizes 100, 200, 400, 800 and 1600. Each size corresponds to the size of the
*environment* in which the agents act, e.g. size 200 corresponds to a 200 x 200
environment. Besides model size, [PPHPC] was also benchmarked with two parameter
sets, simply designated as *parameter set 1* and *parameter set 2*. The latter
typically yields simulations with more agents.

Other setups are associated with computational aspects of model execution, more
specifically **number of threads** (for parallel implementations) and 
**value of the _b_ parameter** (for OD implementation only).

The [dataset][pphpc_data] contains performance data (in the form of [GNU time]
default output) for 10 runs of all setup combinations (i.e. model size,
parameter set, number of threads and value of the _b_ parameter, where
applicable).

<a name="extractperformancedatafromafile-1"></a>

#### 4.2.2\. Extract performance data from a file

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

#### 4.2.3\. Extract execution times from files in a folder

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

#### 4.2.4\. Average execution times and standard deviations

In its most basic usage, the [perfstats] function obtains performance
statistics. In this example, average execution times and standard deviations are
obtained from 10 replications of the Java single-threaded (ST) implementation of
[PPHPC] for size 800, parameter set 2:

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

#### 4.2.5\. Compare multiple setups within the same implementation

A more advanced use case for [perfstats] consists of comparing multiple setups,
associated with different computational sizes, within the same implementation.
For example, considering the Java ST implementation of the [PPHPC] model, the
following instructions analyze how its performance varies for increasing model
sizes:

```matlab
% Specify implementations specs for each model size
st100v2 = struct('sname', '100v2', 'folder', [datafolder '/times/ST'], 'files', 't*100v2*.txt');
st200v2 = struct('sname', '200v2', 'folder', [datafolder '/times/ST'], 'files', 't*200v2*.txt');
st400v2 = struct('sname', '400v2', 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
st800v2 = struct('sname', '800v2', 'folder', [datafolder '/times/ST'], 'files', 't*800v2*.txt');
st1600v2 = struct('sname', '1600v2', 'folder', [datafolder '/times/ST'], 'files', 't*1600v2*.txt');

% Obtain the average time for increasing model sizes
avg_time = perfstats(0, 'ST', {st100v2, st200v2, st400v2, st800v2, st1600v2})
```

```
avg_time =

   1.0e+03 *

    0.0053    0.0361    0.1589    0.6996    2.9572
```

<a name="sameaspreviouswithalog-logplot"></a>

#### 4.2.6\. Same as previous, with a log-log plot

The [perfstats] function can also be used to generate scalability plots. For
this purpose, the computational size, `csize`, must be specified in each
setup, and the first parameter of [perfstats] should be a value between 1
(linear plot) and 4 (log-log plot), as shown in the following code snippet:

```matlab
% Specify implementations specs for each model size, indicating the csize key
st100v2 = struct('sname', '100v2', 'csize', 100, 'folder', [datafolder '/times/ST'], 'files', 't*100v2*.txt');
st200v2 = struct('sname', '200v2', 'csize', 200, 'folder', [datafolder '/times/ST'], 'files', 't*200v2*.txt');
st400v2 = struct('sname', '400v2', 'csize', 400, 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
st800v2 = struct('sname', '800v2', 'csize', 800, 'folder', [datafolder '/times/ST'], 'files', 't*800v2*.txt');
st1600v2 = struct('sname', '1600v2', 'csize', 1600, 'folder', [datafolder '/times/ST'], 'files', 't*1600v2*.txt');

% The first parameter defines the plot type: 4 is a log-log plot
perfstats(4, 'ST', {st100v2, st200v2, st400v2, st800v2, st1600v2});
```

![ex4 2 6_1](https://cloud.githubusercontent.com/assets/3018963/14692567/fc5a2004-074f-11e6-91d1-e82b5260f74c.png)

Error bars showing the standard deviation can be requested by passing a negative
value as the first parameter to [perfstats]:

```matlab
% The value -4 indicates a log-log plot with error bars
perfstats(-4, 'ST', {st100v2, st200v2, st400v2, st800v2, st1600v2});
```

![ex4 2 6_2](https://cloud.githubusercontent.com/assets/3018963/14692568/fc5e537c-074f-11e6-81df-aecfda2c2618.png)

Due to the run time variability being very low, the error bars are not very
useful in this case.

<a name="pphpccompdiffimpl"></a>

<a name="comparedifferentimplementations-1"></a>

#### 4.2.7\. Compare different implementations

Besides comparing multiple setups within the same implementation, the
[perfstats] function is also able to compare multiple setups from a number
implementations. The requirement is that, from implementation to implementation,
the multiple setups are directly comparable, i.e., corresponding implementation
specs should have the same `sname` and `csize` parameters, as shown in the
following commands, where the [NetLogo] \(NL\) and Java single-thread (ST)
[PPHPC] implementations are compared for sizes 100 to 1600, parameter set 1:

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

![ex4 2 7](https://cloud.githubusercontent.com/assets/3018963/14692605/3660f0a2-0750-11e6-9d5d-375a1b5777fe.png)

<a name="speedup-1"></a>

#### 4.2.8\. Speedup

The [speedup] function is used to obtain relative speedups between different
implementations. Using the variables defined in the previous example, the
average, maximum and minimum speedups of the Java ST version over the [NetLogo]
implementation for different model sizes can be obtained with the following
instruction:

```matlab
[s_avg, s_max, s_min] = speedup(0, 1, 'NL', nlv1, 'ST', stv1);
```

The first element of the returned cell, i.e. `s_avg{1}`, contains the speedups:

```
ans =

    1.0000    1.0000    1.0000    1.0000    1.0000
    5.8513    8.2370    5.7070    5.4285    5.4331
```

The second parameter of the [speedup] function indicates the reference
implementation from which to calculate speedups. In this case, specifying 1 will
return speedups against the [NetLogo] implementation. The first row of the
matrix in `s_avg{1}` shows the speedup of the [NetLogo] implementation against
itself, thus it is composed of ones. The second row shows the speedup of the
Java ST implementation versus the [NetLogo] implementation. If the second
parameter of the [speedup] function is a vector, speedups against more than one
implementation are returned in `s_avg`, `s_max` and `s_min`.

Setting the first parameter of [speedup] to 1 will yield a bar plot displaying the
relative speedups:

```matlab
speedup(1, 1, 'NL', nlv1, 'ST', stv1);
```

![ex4 2 8_1](https://cloud.githubusercontent.com/assets/3018963/14692693/e6b122ce-0750-11e6-973d-1742d81974ed.png)

Error bars representing the maximum and minimum speedups can be requested by
passing a negative value as the first parameter:

```matlab
speedup(-1, 1, 'NL', nlv1, 'ST', stv1);
```

![ex4 2 8_2](https://cloud.githubusercontent.com/assets/3018963/14692694/e6b3b32c-0750-11e6-926c-d0ca95795c1f.png)

<a name="speedupformultipleparallelimplementationsandsizes"></a>

#### 4.2.9\. Speedup for multiple parallel implementations and sizes

The [speedup] function is also able to determine speedups between different
implementations for multiple computational sizes. In this example we plot the
speedup of several [PPHPC] parallel Java implementations against the [NetLogo]
and Java single-thread implementations for multiple sizes. This example uses the
`nlv1` and `stv1` variables defined in a [previous example](#pphpccompdiffimpl),
and the plotted results are equivalent to figures 4a and 4b of reference
[\[1\]](#ref1):

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
% This plot is figure 4a of reference [1]
speedup(1, 1, 'NL', nlv1, 'ST', stv1, 'EQ', eqv1t12, 'EX', exv1t12, 'ER', erv1t12, 'OD', odv1t12);

% Place legend in a better position
legend(gca, 'Location', 'NorthWest');
```

![ex4 2 9_1](https://cloud.githubusercontent.com/assets/3018963/14706004/308d5576-07b4-11e6-8509-506cb4af5733.png)

```matlab
% Plot speedup of multiple parallel implementations against Java ST implementation
% This plot is figure 4b of reference [1]
speedup(1, 1, 'ST', stv1, 'EQ', eqv1t12, 'EX', exv1t12, 'ER', erv1t12, 'OD', odv1t12);

% Place legend in a better position
legend(gca, 'Location', 'NorthOutside', 'Orientation', 'horizontal')
```

![ex4 2 9_2](https://cloud.githubusercontent.com/assets/3018963/14706005/30a50b30-07b4-11e6-963c-1b20102b1cbb.png)

<a name="scalabilityofthedifferentimplementationsforincreasingmodelsizes"></a>

#### 4.2.10\. Scalability of the different implementations for increasing model sizes

In a slightly more complex scenario than the one described in a
[previous example](#pphpccompdiffimpl), here we use the [perfstats] function to
plot the scalability of the different [PPHPC] implementations for increasing
model sizes. Using the variables defined in the previous examples, the following
command generates the equivalent to figure 5a of reference [\[1\]](#ref1):

```matlab
perfstats(4, 'NL', nlv1, 'ST', stv1, 'EQ', eqv1t12, 'EX', exv1t12, 'ER', erv1t12, 'OD', odv1t12);
```

![ex4 2 10](https://cloud.githubusercontent.com/assets/3018963/14692845/fdb21130-0751-11e6-9e75-428f92e3b59b.png)

<a name="scalabilityofparallelimplementationsforincreasingnumberofthreads"></a>

#### 4.2.11\. Scalability of parallel implementations for increasing number of threads

The 'computational size', i.e. the `csize` field, defined in the implementation
specs passed to the [perfstats] function can be used in alternative contexts. In
this example, we use the `csize` field to specify the number of threads used to
perform a set of simulation runs or replications. The following commands
will plot the scalability of the several [PPHPC] parallel implementations for an
increasing number of threads. The plotted results are equivalent to figure 6d of
reference [\[1\]](#ref1):

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

% Move legend to a better position
legend(gca, 'Location', 'northeast');
```

![ex4 2 11](https://cloud.githubusercontent.com/assets/3018963/14692932/aba1f486-0752-11e6-8dd9-b5d673dc50ce.png)

<a name="performanceofodstrategyfordifferentvaluesof_b_"></a>

#### 4.2.12\. Performance of OD strategy for different values of _b_

For this example, in yet another possible use of the [perfstats] function,  we
use the `csize` field to specify the value of the _b_ parameter of the [PPHPC]
model Java OD variant. This allows us to analyze the performance of the OD
parallelization strategy for different values of _b_. The plot created by the
following commands is equivalent to figure 7b of reference [\[1\]](#ref1):

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

% Place legend in a better position
legend(gca, 'Location', 'NorthOutside', 'Orientation', 'horizontal')
```

![ex4 2 12](https://cloud.githubusercontent.com/assets/3018963/14693011/49f6088e-0753-11e6-974b-f920b8bb4167.png)

<a name="customperformanceplot"></a>

#### 4.2.13\. Custom performance plot

As previously discussed, it is possible to generate custom plots using the data
returned by [perfstats] and [speedup]. The following code snippet produces a
customized version of the plot generated in the previous example. The resulting
image is a publication quality equivalent of figure 7b in reference
[\[1\]](#ref1):

```matlab
% Get data from perfstats function
p = perfstats(0, '100', od100v2, '200', od200v2, '400', od400v2, '800', od800v2, '1600', od1600v2);

% Values of the b parameter
bvals = [20 50 100 200 500 1000 2000 5000];

% Generate basic plot with black lines
h = loglog(bvals, p', 'k');
set(gca, 'XTick', bvals);

% Set marker styles
set(h(1), 'Marker', 'o', 'MarkerFaceColor', [0.7 0.7 0.7]);
set(h(2), 'Marker', 's', 'MarkerFaceColor', [0.7 0.7 0.7]);
set(h(3), 'Marker', 'o', 'MarkerFaceColor', 'w');
set(h(4), 'Marker', '^', 'MarkerFaceColor', 'k');
set(h(5), 'Marker', 'd', 'MarkerFaceColor', [0.7 0.7 0.7]);

% Draw bold circles indicating best times for each size/b combination
grid on;
hold on;
[my, mi] = min(p, [], 2);
plot(bvals(mi), my, 'ok', 'MarkerSize', 10, 'LineWidth', 2);

% Set limits and add labels
xlim([min(bvals) max(bvals)]);
xlabel('Block size, {\itb}');
ylabel('Time ({\its})');

% Set legend
legend({'100', '200', '400', '800', '1600'}, 'Location', 'NorthOutside', 'Orientation', 'horizontal');
```

![ex4 2 13_1](https://cloud.githubusercontent.com/assets/3018963/14706270/8e7c0e9c-07b5-11e6-8fe8-cbd24c184cec.png)

Although the figure looks appropriate for publication purposes, it can still be
improved by converting it to native LaTeX via the [matlab2tikz] script:

```matlab
% Small adjustments so that figure looks better when converted
grid minor;
set(gca, 'XTickLabel', bvals);

% Convert figure to LaTeX
cleanfigure();
matlab2tikz('standalone', true, 'filename', 'image.tex');
```

Compiling the `image.tex` file with a LaTeX engine yields the following figure:

![ex4 2 13_2](https://cloud.githubusercontent.com/assets/3018963/14706271/8e7c4fce-07b5-11e6-8ed5-09853541b4a4.png)

<a name="showatableinsteadofaplot"></a>

#### 4.2.14\. Show a table instead of a plot

The [times_table] and [times_table_f] functions can be used to create
performance tables formatted in plain text or LaTeX. Using the data defined in a
[previous example](#pphpccompdiffimpl), the following commands produce a plain
text table comparing the [NetLogo] \(NL\) and Java single-thread (ST) [PPHPC]
implementations for sizes 100 to 1600, parameter set 1:

```matlab
% Put data in table format
tdata = times_table(1, 'NL', nlv1, 'ST', stv1);

% Print a plain text table
times_table_f(0, 'NL vs ST', tdata)
```

```
                  -----------------------------------------------
                  |                        NL vs ST             |
-----------------------------------------------------------------
| Imp.   | Set.   |   t(s)     |   std     |  std%  | x     NL  |
-----------------------------------------------------------------
|     NL |  100v1 |       15.9 |     0.359 |   2.26 |         1 |
|        |  200v1 |        100 |      1.25 |   1.25 |         1 |
|        |  400v1 |        481 |      6.02 |   1.25 |         1 |
|        |  800v1 |   2.08e+03 |      9.75 |   0.47 |         1 |
|        | 1600v1 |   9.12e+03 |      94.1 |   1.03 |         1 |
-----------------------------------------------------------------
|     ST |  100v1 |       2.71 |    0.0223 |   0.82 |      5.85 |
|        |  200v1 |       12.2 |     0.219 |   1.80 |      8.24 |
|        |  400v1 |       84.4 |      2.83 |   3.35 |      5.71 |
|        |  800v1 |        383 |      5.04 |   1.32 |      5.43 |
|        | 1600v1 |   1.68e+03 |      78.4 |   4.67 |      5.43 |
-----------------------------------------------------------------
```

In order to produce the equivalent LaTeX table, we set the first parameter to 1
instead of 0:

```matlab
% Print a Latex table
times_table_f(1, 'NL vs ST', tdata)
```

![ex4 2 14](https://cloud.githubusercontent.com/assets/3018963/14706361/f6f1c8cc-07b5-11e6-9c7d-87af968ac115.png)

<a name="complextables"></a>

#### 4.2.15\. Complex tables

The [times_table] and [times_table_f] functions are capable of producing more
complex tables. In this example, we show how to reproduce table 7 of reference
[\[1\]](#ref1), containing times and speedups for multiple model
implementations, different sizes and both parameter sets, showing speedups of
all implementations versus the [NetLogo] and Java ST versions.

The first step consists of defining the implementation specs:

```matlab
% %%%%%%%%%%%%%%%%%%%%%%%%% %
% Specs for parameter set 1 %
% %%%%%%%%%%%%%%%%%%%%%%%%% %

% Define NetLogo implementation specs, parameter set 1
nl100v1 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/NL'], 'files', 't*100v1*.txt');
nl200v1 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/NL'], 'files', 't*200v1*.txt');
nl400v1 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/NL'], 'files', 't*400v1*.txt');
nl800v1 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/NL'], 'files', 't*800v1*.txt');
nl1600v1 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/NL'], 'files', 't*1600v1*.txt');
nlv1 = {nl100v1, nl200v1, nl400v1, nl800v1, nl1600v1};

% Define Java ST implementation specs, parameter set 1
st100v1 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/ST'], 'files', 't*100v1*.txt');
st200v1 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/ST'], 'files', 't*200v1*.txt');
st400v1 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/ST'], 'files', 't*400v1*.txt');
st800v1 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/ST'], 'files', 't*800v1*.txt');
st1600v1 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/ST'], 'files', 't*1600v1*.txt');
stv1 = {st100v1, st200v1, st400v1, st800v1, st1600v1};

% Define Java EQ implementation specs (runs with 12 threads), parameter set 1
eq100v1t12 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/EQ'], 'files', 't*100v1*t12r*.txt');
eq200v1t12 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/EQ'], 'files', 't*200v1*t12r*.txt');
eq400v1t12 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/EQ'], 'files', 't*400v1*t12r*.txt');
eq800v1t12 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/EQ'], 'files', 't*800v1*t12r*.txt');
eq1600v1t12 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/EQ'], 'files', 't*1600v1*t12r*.txt');
eqv1t12 = {eq100v1t12, eq200v1t12, eq400v1t12, eq800v1t12, eq1600v1t12};

% Define Java EX implementation specs (runs with 12 threads), parameter set 1
ex100v1t12 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/EX'], 'files', 't*100v1*t12r*.txt');
ex200v1t12 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/EX'], 'files', 't*200v1*t12r*.txt');
ex400v1t12 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/EX'], 'files', 't*400v1*t12r*.txt');
ex800v1t12 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/EX'], 'files', 't*800v1*t12r*.txt');
ex1600v1t12 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/EX'], 'files', 't*1600v1*t12r*.txt');
exv1t12 = {ex100v1t12, ex200v1t12, ex400v1t12, ex800v1t12, ex1600v1t12};

% Define Java ER implementation specs (runs with 12 threads), parameter set 1
er100v1t12 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/ER'], 'files', 't*100v1*t12r*.txt');
er200v1t12 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/ER'], 'files', 't*200v1*t12r*.txt');
er400v1t12 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/ER'], 'files', 't*400v1*t12r*.txt');
er800v1t12 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/ER'], 'files', 't*800v1*t12r*.txt');
er1600v1t12 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/ER'], 'files', 't*1600v1*t12r*.txt');
erv1t12 = {er100v1t12, er200v1t12, er400v1t12, er800v1t12, er1600v1t12};

% Define Java OD implementation specs (runs with 12 threads, b = 500), parameter set 1
od100v1t12 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/OD'], 'files', 't*100v1*b500t12r*.txt');
od200v1t12 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/OD'], 'files', 't*200v1*b500t12r*.txt');
od400v1t12 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/OD'], 'files', 't*400v1*b500t12r*.txt');
od800v1t12 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/OD'], 'files', 't*800v1*b500t12r*.txt');
od1600v1t12 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/OD'], 'files', 't*1600v1*b500t12r*.txt');
odv1t12 = {od100v1t12, od200v1t12, od400v1t12, od800v1t12, od1600v1t12};

% %%%%%%%%%%%%%%%%%%%%%%%%% %
% Specs for parameter set 2 %
% %%%%%%%%%%%%%%%%%%%%%%%%% %

% Define NetLogo implementation specs, parameter set 2
nl100v2 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/NL'], 'files', 't*100v2*.txt');
nl200v2 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/NL'], 'files', 't*200v2*.txt');
nl400v2 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/NL'], 'files', 't*400v2*.txt');
nl800v2 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/NL'], 'files', 't*800v2*.txt');
nl1600v2 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/NL'], 'files', 't*1600v2*.txt');
nlv2 = {nl100v2, nl200v2, nl400v2, nl800v2, nl1600v2};

% Define Java ST implementation specs, parameter set 2
st100v2 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/ST'], 'files', 't*100v2*.txt');
st200v2 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/ST'], 'files', 't*200v2*.txt');
st400v2 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
st800v2 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/ST'], 'files', 't*800v2*.txt');
st1600v2 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/ST'], 'files', 't*1600v2*.txt');
stv2 = {st100v2, st200v2, st400v2, st800v2, st1600v2};

% Define Java EQ implementation specs (runs with 12 threads), parameter set 2
eq100v2t12 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/EQ'], 'files', 't*100v2*t12r*.txt');
eq200v2t12 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/EQ'], 'files', 't*200v2*t12r*.txt');
eq400v2t12 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/EQ'], 'files', 't*400v2*t12r*.txt');
eq800v2t12 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/EQ'], 'files', 't*800v2*t12r*.txt');
eq1600v2t12 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/EQ'], 'files', 't*1600v2*t12r*.txt');
eqv2t12 = {eq100v2t12, eq200v2t12, eq400v2t12, eq800v2t12, eq1600v2t12};

% Define Java EX implementation specs (runs with 12 threads), parameter set 2
ex100v2t12 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/EX'], 'files', 't*100v2*t12r*.txt');
ex200v2t12 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/EX'], 'files', 't*200v2*t12r*.txt');
ex400v2t12 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/EX'], 'files', 't*400v2*t12r*.txt');
ex800v2t12 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/EX'], 'files', 't*800v2*t12r*.txt');
ex1600v2t12 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/EX'], 'files', 't*1600v2*t12r*.txt');
exv2t12 = {ex100v2t12, ex200v2t12, ex400v2t12, ex800v2t12, ex1600v2t12};

% Define Java ER implementation specs (runs with 12 threads), parameter set 2
er100v2t12 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/ER'], 'files', 't*100v2*t12r*.txt');
er200v2t12 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/ER'], 'files', 't*200v2*t12r*.txt');
er400v2t12 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/ER'], 'files', 't*400v2*t12r*.txt');
er800v2t12 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/ER'], 'files', 't*800v2*t12r*.txt');
er1600v2t12 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/ER'], 'files', 't*1600v2*t12r*.txt');
erv2t12 = {er100v2t12, er200v2t12, er400v2t12, er800v2t12, er1600v2t12};

% Define Java OD implementation specs (runs with 12 threads, b = 500), parameter set 2
od100v2t12 = struct('sname', '100', 'csize', 100, 'folder', [datafolder '/times/OD'], 'files', 't*100v2*b500t12r*.txt');
od200v2t12 = struct('sname', '200', 'csize', 200, 'folder', [datafolder '/times/OD'], 'files', 't*200v2*b500t12r*.txt');
od400v2t12 = struct('sname', '400', 'csize', 400, 'folder', [datafolder '/times/OD'], 'files', 't*400v2*b500t12r*.txt');
od800v2t12 = struct('sname', '800', 'csize', 800, 'folder', [datafolder '/times/OD'], 'files', 't*800v2*b500t12r*.txt');
od1600v2t12 = struct('sname', '1600', 'csize', 1600, 'folder', [datafolder '/times/OD'], 'files', 't*1600v2*b500t12r*.txt');
odv2t12 = {od100v2t12, od200v2t12, od400v2t12, od800v2t12, od1600v2t12};
```

After the implementation specs are defined, we create two intermediate tables:

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
                  ---------------------------------------------------------------------------------------------------------------------
                  |                    Param. set 1                         |                    Param. set 2                         |
---------------------------------------------------------------------------------------------------------------------------------------
| Imp.   | Set.   |   t(s)     |   std     |  std%  | x     NL  | x     ST  |   t(s)     |   std     |  std%  | x     NL  | x     ST  |
---------------------------------------------------------------------------------------------------------------------------------------
|     NL |    100 |       15.9 |     0.359 |   2.26 |         1 |     0.171 |       32.2 |     0.686 |   2.13 |         1 |     0.166 |
|        |    200 |        100 |      1.25 |   1.25 |         1 |     0.121 |        245 |       1.5 |   0.61 |         1 |     0.147 |
|        |    400 |        481 |      6.02 |   1.25 |         1 |     0.175 |   1.07e+03 |      3.63 |   0.34 |         1 |     0.148 |
|        |    800 |   2.08e+03 |      9.75 |   0.47 |         1 |     0.184 |   4.54e+03 |      23.2 |   0.51 |         1 |     0.154 |
|        |   1600 |   9.12e+03 |      94.1 |   1.03 |         1 |     0.184 |   1.96e+04 |      90.9 |   0.46 |         1 |     0.151 |
---------------------------------------------------------------------------------------------------------------------------------------
|     ST |    100 |       2.71 |    0.0223 |   0.82 |      5.85 |         1 |       5.34 |     0.051 |   0.96 |      6.03 |         1 |
|        |    200 |       12.2 |     0.219 |   1.80 |      8.24 |         1 |       36.1 |     0.178 |   0.49 |      6.79 |         1 |
|        |    400 |       84.4 |      2.83 |   3.35 |      5.71 |         1 |        159 |     0.474 |   0.30 |      6.76 |         1 |
|        |    800 |        383 |      5.04 |   1.32 |      5.43 |         1 |        700 |      3.67 |   0.52 |      6.49 |         1 |
|        |   1600 |   1.68e+03 |      78.4 |   4.67 |      5.43 |         1 |   2.96e+03 |       123 |   4.15 |      6.61 |         1 |
---------------------------------------------------------------------------------------------------------------------------------------
|     EQ |    100 |       1.55 |    0.0251 |   1.62 |      10.2 |      1.75 |       1.87 |    0.0287 |   1.53 |      17.2 |      2.85 |
|        |    200 |       2.81 |     0.113 |   4.01 |      35.6 |      4.32 |       7.08 |     0.126 |   1.78 |      34.6 |       5.1 |
|        |    400 |       19.5 |     0.214 |   1.10 |      24.7 |      4.34 |       31.2 |     0.207 |   0.66 |      34.5 |       5.1 |
|        |    800 |       86.1 |      4.26 |   4.95 |      24.1 |      4.45 |        125 |      4.15 |   3.32 |      36.2 |      5.58 |
|        |   1600 |        279 |      4.04 |   1.45 |      32.6 |      6.01 |        487 |      8.48 |   1.74 |      40.1 |      6.07 |
---------------------------------------------------------------------------------------------------------------------------------------
|     EX |    100 |       1.53 |    0.0291 |   1.90 |      10.4 |      1.78 |       2.14 |    0.0587 |   2.75 |      15.1 |       2.5 |
|        |    200 |       2.91 |     0.107 |   3.69 |      34.4 |      4.18 |       8.08 |     0.141 |   1.74 |      30.4 |      4.47 |
|        |    400 |       19.6 |     0.302 |   1.54 |      24.6 |      4.31 |       34.2 |     0.527 |   1.54 |      31.4 |      4.65 |
|        |    800 |       86.5 |      5.46 |   6.31 |        24 |      4.42 |        139 |      5.96 |   4.29 |      32.6 |      5.03 |
|        |   1600 |        282 |      5.49 |   1.95 |      32.4 |      5.96 |        532 |      5.24 |   0.99 |      36.8 |      5.56 |
---------------------------------------------------------------------------------------------------------------------------------------
|     ER |    100 |       7.29 |     0.325 |   4.46 |      2.18 |     0.372 |       8.39 |     0.148 |   1.76 |      3.83 |     0.636 |
|        |    200 |       16.4 |      0.77 |   4.68 |       6.1 |      0.74 |       17.9 |     0.252 |   1.41 |      13.7 |      2.02 |
|        |    400 |       37.2 |     0.204 |   0.55 |        13 |      2.27 |       45.9 |     0.285 |   0.62 |      23.4 |      3.46 |
|        |    800 |        111 |      3.37 |   3.02 |      18.6 |      3.43 |        159 |      3.21 |   2.02 |      28.5 |      4.39 |
|        |   1600 |        332 |       3.5 |   1.06 |      27.5 |      5.06 |        553 |      8.03 |   1.45 |      35.3 |      5.34 |
---------------------------------------------------------------------------------------------------------------------------------------
|     OD |    100 |       1.36 |    0.0158 |   1.16 |      11.7 |         2 |          2 |    0.0331 |   1.66 |      16.1 |      2.68 |
|        |    200 |       2.68 |      0.07 |   2.61 |      37.4 |      4.54 |       6.64 |     0.109 |   1.64 |        37 |      5.44 |
|        |    400 |       19.2 |     0.199 |   1.04 |      25.1 |       4.4 |       29.1 |     0.122 |   0.42 |      36.9 |      5.46 |
|        |    800 |       82.9 |      2.27 |   2.73 |        25 |      4.61 |        118 |         3 |   2.55 |      38.6 |      5.95 |
|        |   1600 |        292 |      8.51 |   2.91 |      31.2 |      5.74 |        479 |      9.32 |   1.95 |      40.8 |      6.18 |
---------------------------------------------------------------------------------------------------------------------------------------
```

Finally, we produce a LaTeX table, as shown in reference [\[1\]](#ref1):

```matlab
% LaTex table
times_table_f(1, 'Param. set 1', data_v1, 'Param. set 2', data_v2)
```

![ex4 2 15](https://cloud.githubusercontent.com/assets/3018963/14706360/f6f17d18-07b5-11e6-926f-2314f9d59206.png)

<a name="license"></a>

## 5\. License

[MIT License](LICENSE)

<a name="references"></a>

## 6\. References

<a name="ref1"></a>

[\[1\]](#ref1) Fachada N, Lopes VV, Martins RC, Rosa AC. (2016) Parallelization
Strategies for Spatial Agent-Based Models. *International Journal of Parallel
Programming*. https://doi.org/10.1007/s10766-015-0399-9 (arXiv version available
at http://arxiv.org/abs/1507.04047)

[Matlab]: http://www.mathworks.com/products/matlab/
[Octave]: https://gnu.org/software/octave/
[NetLogo]: https://ccl.northwestern.edu/netlogo/
[sorttest.c]: https://github.com/fakenmc/sorttest_c
[alternative]: http://stackoverflow.com/questions/673523/how-to-measure-execution-time-of-command-in-windows-command-line
[sort_data]: data
[pphpc_data]: http://dx.doi.org/10.5281/zenodo.34049
[matlab2tikz]: http://www.mathworks.com/matlabcentral/fileexchange/22022-matlab2tikz-matlab2tikz
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

