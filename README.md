[![DOI](https://zenodo.org/badge/142482470.svg)](https://zenodo.org/badge/latestdoi/142482470)

This repository provides the code and result figures with the paper:

Dynamic load balancing enables large-scale flux variability analysis.

Authors: Marouen Ben Guebila and Ines Thiele

Contact: marouen.b.guebila [AT] gmail.com

### Usage
Please refer to the [UserGuide](UserGuide.md) for veryfastFVA (VFFVA) usage.

Add the project folder to your MATLAB path and save it.

For the comparison with fastFVA (FFVA), you can install FFVA [here](http://wwwen.uni.lu/lcsb/research/mol_systems_physiology/fastfva).

### Paper figures and tables
Regarding VFFVA, please set environment variables `OMP_PROC_BIND=FALSE` and export `OMP_SCHEDULE=dynamic,50` for the following section:

1. Table2: (Running times of small models: Ecoli_core, EcoliK12 and P_Putida).

	You can use run `outputSmallModelTable.m` in `lib` directory with the pre-computed result files.

	You can obtain your own benchmarking results through calling:
	- `smallModelsAnalysisFFVA_A.sh`: runs FFVA on small models and saves analysis time only.
	- `smallModelsAnalysisFFVA_LA.sh`: runs FFVA on small models and saves loading and analysis time.
	- `smallModelsAnalysisVFFVA_LA.sh`: runs VFFVA on small models and saves loading and analysis time.

2. Figure2: (Running times of large models: Recon2 and E_Matrix).

	You can run the first section of `statTest.m` in `lib` directory to plot the figure with pre-computed results.

	To recompute the benchamarking results, please run:
	- `largeModelsAnalysisFFVA_LA.sh`: runs FFVA on large models and saves loading and analysis time.
	- `largeModelsAnalysisVFFVA_LA.sh`: runs VFFVA on large models and saves loading and analysis time.

3. Figure3: (Running times of E_Matrix_coupled).

	In the following section, please set `OMP_PROC_BIND=TRUE`.
	You can run the second section of `statTest.m` in `lib` directory to plot the figure with pre-computed results.

	To recompute the benchmarking results, please run:
	- `EmatrixCoupledAnalysisFFVA_LA.sh`: runs FFVA on E_Matrix_coupled model and saves loading and analysis time.
	- `EmatrixCoupledAnalysisVFFVA_LA.sh`: runs VFFVA on E_Matrix_coupled model and saves loading and analysis time.

### Presentations
VFFVA has been presented in the poster session of the [2017 International Conference on Systems Biology of Human Disease in Heidelberg, Germany.](https://www.sbhd-conference.org/).
