[![DOI](https://zenodo.org/badge/142482470.svg)](https://zenodo.org/badge/latestdoi/142482470)
[![TRAVIS](https://travis-ci.com/marouenbg/VFFVA.svg?branch=master)](https://travis-ci.com/marouenbg/VFFVA)

This repository provides the code and result figures with the paper:

Dynamic load balancing enables large-scale flux variability analysis.

contact: [Marouen Ben Guebila](emailto:marouen.b.guebila@gmail.com)

### Usage
Please refer to the [UserGuide](UserGuide.md) for veryfastFVA (VFFVA) usage.

Add the project folder to your MATLAB path and save it.

For the comparison with fastFVA (FFVA), you can install FFVA [here](http://wwwen.uni.lu/lcsb/research/mol_systems_physiology/fastfva).

### Motivation
FVA [^1] is the workhorse of metabolic modeling. It allows to characterize the boundaries of the solution space of a metabolic model and delineates the bounds
for reaction rates.
FFVA [^2] brought considerable speed up over FVA through the use C over MATLAB, and the reuse of the same LP object which allows to avoid solving the problem from
scratch for every reaction. Although, with the increase of the size of metabolic models, FFVA is run usually in parallel. 

### Presentations
VFFVA has been presented in the poster session of the [2017 International Conference on Systems Biology of Human Disease in Heidelberg, Germany.](https://www.sbhd-conference.org/).

[^1]: [The effects of alternate optimal solutions in constraint-based genome-scale metabolic models.](https://www.ncbi.nlm.nih.gov/pubmed/14642354)
[^2]: [Computationally efficient flux variability analysis.](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-489)



