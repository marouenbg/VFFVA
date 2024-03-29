[![DOI](https://zenodo.org/badge/142482470.svg)](https://zenodo.org/badge/latestdoi/142482470)
[![TRAVIS](https://travis-ci.com/marouenbg/VFFVA.svg?branch=master)](https://travis-ci.com/marouenbg/VFFVA)
[![codecov](https://codecov.io/gh/marouenbg/VFFVA/branch/master/graph/badge.svg)](https://codecov.io/gh/marouenbg/VFFVA)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/marouenbg/ACHR.cu/blob/master/LICENSE.txt)

This repository provides the code and result figures with the paper:

[VFFVA: dynamic load balancing enables large-scale flux variability analysis.](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-020-03711-2)

Contact: [Marouen Ben Guebila](mailto:marouen.b.guebila@gmail.com)

### Usage
The supported languages are: C (veryfastFVA.c) with wrappers in  MATLAB (VFFVA.m) and Python (VFFVA.py). IBM CPLEX has stopped its support for MATLAB since version 12.10, therefore VFFVA can be an alternative to access new CPLEX versions through its C API.

Please refer to the [documentation](https://vffva.readthedocs.io/en/latest/) and the [UserGuide](UserGuide.md) for veryfastFVA (VFFVA) usage.

In MATLAB, add the project folder to your MATLAB path and save it, then use `VFFVA()`. In Python, `import VFFA` to use `VFFVA()`.

For the comparison with fastFVA (FFVA), you can install FFVA [here](http://wwwen.uni.lu/lcsb/research/mol_systems_physiology/fastfva).

### Installation
Please install each of the 3 dependencies separately as specified in the [documentation](https://vffva.readthedocs.io/en/latest/).
- IBM ILOG CPLEX [free academic version](https://www.ibm.com/products/ilog-cplex-optimization-studio)
- [MPI](www.open-mpi.org)
- OpenMP is installed by default on most platforms except recent MacOS versions that require a dedicated installation. 

### Motivation
FVA³ is the workhorse of metabolic modeling. It allows to characterize the boundaries of the solution space of a metabolic model and delineates the bounds
for reaction rates.

FFVA¹ brought considerable speed up over FVA through the use C over MATLAB, and the reuse of the same LP object which allows to avoid solving the optimization problem from
scratch for every reaction. Although, with the increase of the size of metabolic models, FFVA is run usually in parallel. 

The parallel setting for the common FVA implementations<sup>1,2</sup> relies on dividing the 2n tasks (one maximization and one minimization for the n reactions) among the p workers equally.
Such as each worker gets 2n/p reactions to process. This is called **static load balancing** and would be the optimal startegy if each of the n reactions is solved in equal times (left figure).

Nevertheless, in most metabolic models there are several ill-conditioned reactions that require longer solution time thereby slowing the worker processing them which
impacts the overall process, as the workers have to synchronize at the end to reduce the results (middle figure).

One approach would be to estimate *a priori* the solution time of each reaction and distribute to each worker 2n/p reactions of equal solution time. But, estimating the solution
time of a reaction *a priori* could be a challenging task.

VFFVA performs **dynamic load blancing**. In runtime, each worker gets a small chunk of reactions to process and once finished, gets another one and so on (right figure). This setting allows i)
fast workers to process more reactions which allows all the workers to finish at the same time, and ii) does not require *a priori* balancing as the workers will automatically
get chunk of reactions assigned from the queue. 

![Dynamic load balancing](./dynamicBalancing-01.png)
### Presentations
VFFVA has been presented in the poster session of the [2017 International Conference on Systems Biology of Human Disease in Heidelberg, Germany.](https://www.sbhd-conference.org/)

### References
¹[Gudmundsson and Thiele. Computationally efficient flux variability analysis.](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-489)

²[Heirendt et al. DistributedFBA.jl: high-level, high-performance flux balance analysis in Julia](https://academic.oup.com/bioinformatics/article/33/9/1421/2908434)

³[Mahadevan and Schilling. The effects of alternate optimal solutions in constraint-based genome-scale metabolic models.](https://www.ncbi.nlm.nih.gov/pubmed/14642354)

### License

The software is free and is licensed under the MIT license, see the file [LICENSE](<https://github.com/marouenbg/VFFVA/blob/master/LICENSE.txt>) for details.

### Feedback/Issues

Please check the [documentation](https://vffva.readthedocs.io/en/latest/) first and report any issues to the [issues page](https://github.com/marouenbg/VFFVA/issues).

### Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md).
By participating in this project you agree to abide by its terms.
