## Analysis of performance data

These scripts are generic and work with any computational experiment profiled
with the [GNU time] command.

### File format

Default output of [GNU time] command.

**Example:**

```
512.66user 2.17system 8:01.34elapsed 106%CPU (0avgtext+0avgdata 1271884maxresident)k
0inputs+2136outputs (0major+49345minor)pagefaults 0swaps
```

### Utilities

* [get_time](get_time.m) - Given a file containing the default output of the GNU
time command, extract the user, system and elapsed time in seconds, as well as 
the percentage of CPU usage.

* [gather_times](gather_times.m) - Load execution times from all files in a 
given folder.

* [perfstats](perfstats.m) - Determine mean times and respective standard 
deviations of a computational experiment using folders of files containing the 
default output of the GNU time command, optionally plotting a scalability graph 
if different setups correspond to different computational work sizes.

* [speedup](speedup.m) - Determine speedups using folders of files obtained with
GNU time command, and optionally plot speedups in a bar plot.

* [times_table](times_table.m) - Returns a matrix with useful contents for using
in tables for publication, namely times (in seconds), absolute standard
deviations (seconds), relative standard deviations, speedups (vs the 
implementations specified in the `compare` input variable).

* [times_table_f](times_table_f.m) - Print a timing table formatted in plain 
text or in LaTeX (the latter requires the [siunitx], [multirow] and [booktabs] 
packages).

### Examples

These examples use the datasets available at 
[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.34049.svg)](http://dx.doi.org/10.5281/zenodo.34049).
Unpack the datasets to any folder and put the complete path to this folder in 
variable `datafolder`, e.g.:

```matlab
datafolder = 'path/to/datasets';
```

These datasets correspond to the results presented in the manuscript
[Parallelization Strategies for Spatial Agent-Based Models](http://arxiv.org/abs/1507.04047).

#### Example 1. Extract performance data from a file

* Extract performance data from file:

```matlab
p = get_time([datafolder '/times/NL/time100v1r1.txt'])
```

* See CPU usage (percentage):

```matlab
p.cpu
```

#### Example 2. Extract execution times from files in a folder

* Extract execution times from files:

```matlab
exec_time = gather_times('NetLogo', [datafolder '/times/NL'], 'time100v1*.txt')
```

* See execution times:

```matlab
exec_time.elapsed
```

#### Example 3. Average execution times and standard deviations

* Get average execution times and standard deviations from ten simulation runs 
of the Java implementation of PPHPC (single-thread, ST) for size 800, parameter
set 2.

```matlab
st800v2 = struct('sname', '800v1', 'folder', [datafolder '/times/ST'], 'files', 't*800v2*.txt');
[avg_time, std_time] = perfstats(0, 'ST', {st800v2})
```

#### Example 4. Compare multiple setups within the same implementation

* For the same PPHPC implementation (Java ST), compare performance for sizes 
100, 200, 400, 800 and 1600.

```matlab
st100v2 = struct('sname', '100v2', 'folder', [datafolder '/times/ST'], 'files', 't*100v2*.txt');
st200v2 = struct('sname', '200v2', 'folder', [datafolder '/times/ST'], 'files', 't*200v2*.txt');
st400v2 = struct('sname', '400v2', 'folder', [datafolder '/times/ST'], 'files', 't*400v2*.txt');
st800v2 = struct('sname', '800v2', 'folder', [datafolder '/times/ST'], 'files', 't*800v2*.txt');
st1600v2 = struct('sname', '1600v2', 'folder', [datafolder '/times/ST'], 'files', 't*1600v2*.txt');
avg_time = perfstats(0, 'ST', {st100v2, st200v2, st400v2, st800v2, st1600v2})
```

#### Example 5. Same as previous, with a log-log plot

* Compare performance of the Java ST implementation for sizes 100, 200, 400, 800
and 1600, and plot a scalability graph.

* In this case, implementation specs must specify a computational size, `cize`,
and [perfstats](perfstats.m) must be called with 1 instead of 0 in the first 
argument.

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

![ex06](https://cloud.githubusercontent.com/assets/3018963/11914710/b524dd5a-a67e-11e5-82d0-8f2ef0401e30.png)

#### Example 7. Speedup

* Using the variables defined in the previous example, plot the speedup of the 
Java ST version vs the NetLogo implementation for different model sizes.

```matlab
speedup(1, 1, 'NL', nlv1, 'ST', stv1);
```

![ex07](https://cloud.githubusercontent.com/assets/3018963/11914711/b5259966-a67e-11e5-9faf-32770a2f080e.png)

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
```

![perf_ex08_1](https://cloud.githubusercontent.com/assets/3018963/11870035/226e2796-a4bc-11e5-9b63-1f9b8f51fa75.png)

```matlab
% Plot speedup of multiple parallel implementations against Java ST implementation
% This plot is figure 4b of the specified manuscript
speedup(1, 1, 'ST', stv1, 'EQ', eqv1t12, 'EX', exv1t12, 'ER', erv1t12, 'OD', odv1t12);
```

![ex08_1](https://cloud.githubusercontent.com/assets/3018963/11914712/b52c33b6-a67e-11e5-8ea6-489f025329f6.png)
![ex08_2](https://cloud.githubusercontent.com/assets/3018963/11914714/b52fdcbe-a67e-11e5-8da2-7aae819e1337.png)

#### Example 9. Scalability of the different implementations for increasing model sizes

* Plot the scalability of the different implementations for increasing model 
sizes. This example uses the variables defined in the previous examples, and the
plotted results are equivalent to figure 5a of the aforementioned manuscript.

```matlab
perfstats(4, 'NL', nlv1, 'ST', stv1, 'EQ', eqv1t12, 'EX', exv1t12, 'ER', erv1t12, 'OD', odv1t12);
```

![ex09](https://cloud.githubusercontent.com/assets/3018963/11914713/b52f195a-a67e-11e5-9a69-761526351f6d.png)

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

![ex10](https://cloud.githubusercontent.com/assets/3018963/11914715/b53d4b74-a67e-11e5-85e3-4cd1349152a1.png)

#### Example 11. Performance of OD strategy for different values of _b_

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

![ex11](https://cloud.githubusercontent.com/assets/3018963/11914716/b543721a-a67e-11e5-9a34-cfd1eac7a3ba.png)

#### Example 12. Same as example 6, but show a table instead of a plot

* Compare NetLogo (NL) and Java single-thread (ST) PPHPC implementations
for sizes 100 to 1600, parameter set 1 (using data from Example 6).

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

```matlab
% Print a Latex table
times_table_f(1, 'NL vs ST', tdata)
```

![ex12](https://cloud.githubusercontent.com/assets/3018963/11914717/b543e4ca-a67e-11e5-9d57-6348aabb91ad.png)

#### Example 13. Complex tables

* Print table 7 of the specified manuscript, containing times and speedups for
different model implementations, different sizes and different parameter sets,
showing speedups of all implementations versus the NetLogo and Java ST 
versions. 

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

% %%%%%%%%%%%%%%%%%%% %
% Intermediate tables %
% %%%%%%%%%%%%%%%%%%% %

% Parameter set 1
data_v1 = times_table([1 2], 'NL', nlv1, 'ST', stv1, 'EQ', eqv1t12, 'EX', exv1t12, 'ER', erv1t12, 'OD', odv1t12);

% Parameter set 2
data_v2 = times_table([1 2], 'NL', nlv2, 'ST', stv2, 'EQ', eqv2t12, 'EX', exv2t12, 'ER', erv2t12, 'OD', odv2t12);

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

```matlab
% Latex table
times_table_f(1, 'Param. set 1', data_v1, 'Param. set 2', data_v2)
```

![ex13](https://cloud.githubusercontent.com/assets/3018963/11914718/b54b70be-a67e-11e5-8ed0-5d3c99d2e93f.png)

[GNU time]: https://www.gnu.org/software/time/
[siunitx]: https://www.ctan.org/pkg/siunitx
[multirow]: https://www.ctan.org/pkg/multirow
[booktabs]: https://www.ctan.org/pkg/booktabs
