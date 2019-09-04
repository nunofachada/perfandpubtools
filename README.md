[![Latest release](https://img.shields.io/github/release/fakenmc/perfandpubtools.svg)](https://github.com/fakenmc/perfandpubtools/releases)
[![Documentation](https://img.shields.io/badge/documentation-user_guide-brightgreen.svg)](docs/userguide.md)
[![MIT Licence](https://img.shields.io/badge/license-MIT-yellowgreen.svg)](https://opensource.org/licenses/MIT/)

PerfAndPubTools
===============

## What is PerfAndPubTools?

**PerfAndPubTools** consists of a set of [MATLAB]/[Octave] functions for
analyzing software performance benchmark results and producing associated
publication quality materials, mainly oriented towards _LaTeX_ outputs. If you
use this software please cite the following reference:

* Fachada N, Lopes VV, Martins RC, Rosa AC., (2016).
PerfAndPubTools – Tools for Software Performance Analysis and Publishing of
Results. *Journal of Open Research Software*. 4(1), p.e18. 
http://doi.org/10.5334/jors.115

The [PerfAndPubTools User Guide](docs/userguide.md) describes the basic concepts
and explains how to use the package by presenting two different use cases
exemplifying the provided functionality.

## Papers authored with the help of PerfAndPubTools

Here's a list of papers authored with the help of **PerfAndPubTools**. If you
want your paper listed here, fork this repository, edit this file and open a
pull request. Alternatively,
[open an issue](https://github.com/fakenmc/perfandpubtools/issues).

* Fernandes CM, Fachada N, Merelo J, Rosa AC. (2019)
Steady state particle swarm.
*PeerJ Computer Science* 5:e202
https://doi.org/10.7717/peerj-cs.202

* Fachada N, Lopes VV, Martins RC, Rosa AC. (2017)
Parallelization strategies for spatial agent-based models. *International
Journal of Parallel Programming*. 45(3):449–481.
http://dx.doi.org/10.1007/s10766-015-0399-9
([arXiv preprint](http://arxiv.org/abs/1507.04047))

* Fachada N, Lopes VV, Martins RC, Rosa AC. (2017)
cf4ocl: A C framework for OpenCL,
[Science of Computer Programming](https://www.journals.elsevier.com/science-of-computer-programming),
143:9–19, http://www.sciencedirect.com/science/article/pii/S0167642317300540
([arXiv preprint](https://arxiv.org/abs/1609.01257))

* Fachada N, Rosa AC. (2017)
Assessing the feasibility of OpenCL CPU implementations for agent-based simulations,
[Proceedings of the 5th International Workshop on OpenCL (IWOCL 2017)](http://www.iwocl.org/),
Article No. 4,
http://doi.acm.org/10.1145/3078155.3078174

## Output examples

![Average speedup over selection sort](https://cloud.githubusercontent.com/assets/3018963/14715384/84054192-07e0-11e6-9da1-88bb990f4588.png)
![Speedup over Bubble sort, LaTeX version](https://cloud.githubusercontent.com/assets/3018963/14691634/3681a91a-074a-11e6-818c-498c68d2f8f0.png)
![Scalability of sorting algorithms with vector size](https://cloud.githubusercontent.com/assets/3018963/14691915/ca03003e-074b-11e6-85fd-155e7cf2314a.png)
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
![Scalability of on-demand parallelization strategy with block size for different simulation sizes](https://cloud.githubusercontent.com/assets/3018963/14706271/8e7c4fce-07b5-11e6-8ed5-09853541b4a4.png)
![Performance table for different parallelization strategies](https://cloud.githubusercontent.com/assets/3018963/14706360/f6f17d18-07b5-11e6-926f-2314f9d59206.png)

## Documents

* [User Guide](docs/userguide.md)
* [Contributing guidelines](CONTRIBUTING.md)
* [Code of conduct](CODE_OF_CONDUCT.md)

## License

[MIT License](LICENSE)

[Matlab]: http://www.mathworks.com/products/matlab/
[Octave]: https://gnu.org/software/octave/

