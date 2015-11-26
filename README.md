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

#### Example 5. Same as previous, with a plot

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
perfstats(1, 'ST', {st100v2, st200v2, st400v2, st800v2, st1600v2})
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
perfstats(1, 'NL', nlv1, 'ST', stv1)
```

[GNU time]: https://www.gnu.org/software/time/

