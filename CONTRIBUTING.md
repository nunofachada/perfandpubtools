# How to contribute

This project accepts contributions from anyone interested in improving it. To
do so, follow these steps:

1. [Fork it](https://github.com/fakenmc/perfandpubtools/fork)
2. Improve it, respecting the <a href="#codstand">coding standards</a> and
using proper [commit messages](https://chris.beams.io/posts/git-commit/)
3. Submit a [pull request](https://help.github.com/articles/creating-a-pull-request)

Your work will then be reviewed as soon as possible (suggestions about some
changes, improvements or alternatives may be given).

Do not forget to verify that
[all tests pass](https://github.com/fakenmc/perfandpubtools/blob/master/tests/tests_all.m),
adding [new ones](https://github.com/fakenmc/perfandpubtools/tree/master/tests) if
necessary. Also, do not forget to update the [documentation](docs/userguide.md)
if relevant.

<a name="codstand" />

# Coding standards

* Code must work in [MATLAB] (>= 2013a) and [Octave] (>= 4.0.0)
* MATLAB-style documentation and comments
* Indentation: four spaces, no tabs
* Encoding: UTF-8
* Line size limit: 80 chars
* Newlines: Unix style, i.e. LF or \n
* Function names: lower_case_with_underscores_allowed_butnotrequired

# Attribution

This document is partially adapted from the [TempoSimple](https://github.com/gnugat-legacy/tempo-simple/blob/master/CONTRIBUTING.m)
contributing guidelines.

[MATLAB]: http://www.mathworks.com/products/matlab/
[Octave]: https://gnu.org/software/octave/
