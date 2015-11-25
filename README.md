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

* [scal_plot](scal_plot.m) - Determine mean times and respective standard 
deviations of computational experiments using folders of files containing the 
default output of the GNU time command,  optionally plotting a scalability graph
if different experiments correspond to different computational work sizes

### Examples

These examples use the datasets available at 
[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.34053.svg)](http://dx.doi.org/10.5281/zenodo.34053).
Unpack the datasets to any folder and put the complete path to this folder in
variable `datafolder`, e.g.:

```matlab
datafolder = 'path/to/datasets/';
```

#### Example 1. Extract performance data from a file

* Extract performance data from file

```matlab
p = get_time([datafolder 'times/NL/time100v1r1.txt'])
```

* See CPU usage (percentage)

```matlab
p.cpu
```

#### Example 2. Extract execution lengths from files in a folder

* Extract execution lengths from files

```matlab
exec_len = gather_times('NetLogo', [datafolder 'times/NL'], 'time100v1*.txt')
```

* See execution lengths

```matlab
exec_len.elapsed
```

#### Example 3. Get average execution lengths and standard deviations from a number of simulation runs




[GNU time]: https://www.gnu.org/software/time/
