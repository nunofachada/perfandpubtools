## Analysis of performance data

These scripts are generic and work with any computational experiment profiled
with the [GNU time] command.

These scripts are currently not working with Octave due to `strread` not yet 
supporting some format specifiers used in the [get_time](get_time.m) 
function.

### File format

Default output of [GNU time] command.

**Example:**

```
512.66user 2.17system 8:01.34elapsed 106%CPU (0avgtext+0avgdata 1271884maxresident)k
0inputs+2136outputs (0major+49345minor)pagefaults 0swaps
```

### Utilities

* [get_time](get_time.m) - Given a file containing the default 
output of the GNU time command, extract the user, system and elapsed 
time in seconds, as well as the percentage of CPU usage.

* [gather_times](gather_times.m) - Load execution times from all 
files in a given folder.

* [perfstats](perfstats.m) - Determine mean times and respective 
standard deviations of a computational experiments using folders of 
files containing the default output of the GNU time command, optionally 
plotting a scalability graph if different setups correspond to different
computational work sizes.

* [speedup](speedup.m) - Determine speedups using folders of files 
obtained with GNU time command, and optionally plot speedups in a bar 
plot.

* [times_table](times_table.m) - Returns a matrix with useful contents 
for using in tables for publication, namely times (in seconds), absolute 
standard deviations (seconds), relative standard deviations, speedups 
(vs the implementations specified in the `compare` input variable).

* [times_table_f](times_table_f.m) - Print a timing table formatted in 
plain text or in Latex.

### Examples

These examples use the datasets available at 
[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.34053.svg)](http://dx.doi.org/10.5281/zenodo.34053).
Unpack the datasets to any folder and put the complete path to this folder in
variable `datafolder`, e.g.:

```matlab
datafolder = 'path/to/datasets';
```

These datasets correspond to the results presented in the manuscript
"[Parallelization Strategies for Spatial Agent-Based Models](http://arxiv.org/abs/1507.04047)".

#### Example 1. Extract performance data from a file

* Extract performance data from file

```matlab
p = get_time([datafolder 'times/NL/time100v1r1.txt'])
```

* See CPU usage (percentage)

```matlab
p.cpu
```

#### Example 2. Extract execution times from files in a folder

* Extract execution times from files

```matlab
exec_time = gather_times('NetLogo', [datafolder '/times/NL'], 'time100v1*.txt')
```

* See execution times

```matlab
exec_time.elapsed
```

#### Example 3. Average execution times and standard deviations

* Get average execution times and standard deviations from ten 
simulation runs of the Java implementation of PPHPC (single-thread, ST)
for size 800, parameter set 2.

```matlab
st800v2 = struct('sname', '800v1', 'folder', [datafolder '/times/ST'], 'files', 't*800v2*.txt');
[avg_time, std_time] = perfstats(0, 'ST', {st800v2})
```

#### Example 4. Compare multiple setups within the same implementation

* For the same PPHPC implementation (Java ST), compare performance for
sizes 100, 200, 400, 800 and 1600.

```matlab
st100v2 = struct('sname', '100v2', 'folder', [datafolder '/times/ST'], 'files', 't*100v2*.txt');
st200v2 = struct('sname', '200v2', 'folder', [datafolder '/times/ST'], 'files', 't*200v2*.txt');
st400v2 = struct('sname', '400v2', 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
st800v2 = struct('sname', '800v2', 'folder', [datafolder '/times/ST'], 'files', 't*800v2*.txt');
st1600v2 = struct('sname', '1600v2', 'folder', [datafolder '/times/ST'], 'files', 't*1600v2*.txt');
avg_time = perfstats(0, 'ST', {st100v2, st200v2, st400v2, st800v2, st1600v2})
```

#### Example 5. Same as previous, with a log-log plot

* Compare performance of the Java ST implementation for sizes 100, 200, 
400, 800 and 1600, and plot a scalability graph.

* In this case, implementation specs must specify a computational size
and `perfstats` must be called with 1 instead of 0 in the first 
argument.

```matlab
st100v2 = struct('sname', '100v2', 'csize', 100, 'folder', [datafolder '/times/ST'], 'files', 't*100v2*.txt');
st200v2 = struct('sname', '200v2', 'csize', 200, 'folder', [datafolder '/times/ST'], 'files', 't*200v2*.txt');
st400v2 = struct('sname', '400v2', 'csize', 400, 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
st800v2 = struct('sname', '800v2', 'csize', 800, 'folder', [datafolder '/times/ST'], 'files', 't*800v2*.txt');
st1600v2 = struct('sname', '1600v2', 'csize', 1600, 'folder', [datafolder '/times/ST'], 'files', 't*1600v2*.txt');

# The first parameter defines the plot type: 4 is a log-log plot
perfstats(4, 'ST', {st100v2, st200v2, st400v2, st800v2, st1600v2});
```

#### Example 6. Compare different implementations

* Compare NetLogo (NL) and Java single-thread (ST) PPHPC implementations
for sizes 100 to 1600, parameter set 1.

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

#### Example 7. Speedup

* Using the variables defined in the previous example, plot the speedup of the 
Java ST version vs the NetLogo implementation for different model sizes.

```matlab
speedup(1, 1, 'NL', nlv1, 'ST', stv1);
```

#### Example 8. Speedup for multiple parallel implementations and sizes

* Plot speedup of parallel implementations against NL and ST for multiple sizes.
This example uses the variables defined in example 6, and the plotted results 
are equivalent to figures 4a and 4b of the 
"[Parallelization Strategies...](http://arxiv.org/abs/1507.04047)"
manuscript.

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

% Plot speedup of multiple parallel implementations against Java ST implementation
% This plot is figure 4b of the specified manuscript
speedup(1, 1, 'ST', stv1, 'EQ', eqv1t12, 'EX', exv1t12, 'ER', erv1t12, 'OD', odv1t12);
```

#### Example 9. Scalability of the different implementations for increasing model sizes

* Plot the scalability of the different implementations for increasing model 
sizes. This example uses the variables defined in the previous examples, and the
plotted results are equivalent to figure 5a of the aforementioned manuscript.

```matlab
perfstats(4, 'NL', nlv1, 'ST', stv1, 'EQ', eqv1t12, 'EX', exv1t12, 'ER', erv1t12, 'OD', odv1t12);
```

#### Example 10. Scalability of parallel implementations for increasing number of threads

* Plot the scalability of parallel implementations for increasing number of 
threads. The plotted results are equivalent to figure 6d of the aforementioned 
manuscript.

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

#### Example 11. Performance of OD strategy for different values of b

* Plot the performance of OD for different values of _b_ (12 threads). The 
plotted results are equivalent to figure 7b of the aforementioned manuscript.

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

[GNU time]: https://www.gnu.org/software/time/

