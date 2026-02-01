# ConnectivityAdaptation
Matlab code to reproduce figures for "Adaptation modulates effective connectivity and network stability" by Thomas J. Richner, Martynas Dervinis, and Brian N. Lundstrom

This repo is an organized subset and fixed snapshot of two other repos:
https://github.com/TomRichner/RandomMatrixTheory
https://github.com/TomRichner/FractionalReservoir

The code here reproduces the two main figures in 
"Adaptation modulates effective connectivity and network stability"

## Quick Start

To reproduce all figures, run the master script from the project root:

```matlab
run_all_figures.m
```

This script sequentially executes the figure-generating scripts with pauses between each to allow review. The Parallel Computing Toolbox is recommended for the last portion of fiure 2, but but it not required (falls back to serial execution; ~25 minutes without parallelization).

## RandomMatrixTheory
RMT_examples.m creates figure 1
RMT.m is a class for analyzing sparse random matrices based on Harris et al. 2023

## ConnectivityAdaptation
scripts/setup_paths.m sets the paths so that Matlab knows where to find the code for figure 2
scripts/Fig_2_single_vs_dual_adaptation_example.m makes the example time series to see the effect of adaptation and stimulation
scripts/Fig_2_fraction_excitatory_analysis.m runs the experiment 25 times for statistical analysis and generates more subfigures.

## Documentation

The `docs/` folder contains detailed documentation organized into three subdirectories:

### EquationsParametersDocs/
Mathematical foundations and parameter references:

- **[parameter_table.md](docs/EquationsParametersDocs/parameter_table.md)** – Complete parameter table for Figure 2, including system equations, state variables, connection matrix parameters, time constants, adaptation settings, and simulation configuration.
- **[J_eff_notes.md](docs/EquationsParametersDocs/J_eff_notes.md)** – Derivation of the effective connectivity Jacobian $J_{\text{eff}}(x,a,b)$, showing how adaptation modulates connectivity by treating adaptation variables as frozen parameters.
- **[system_equations.md](docs/EquationsParametersDocs/system_equations.md)** – The core SRNN differential equations in LaTeX format.

### RandomMatrixTheoryDocs/
Random Matrix Theory background and class documentation:

- **[RMT_notes.md](docs/RandomMatrixTheoryDocs/RMT_notes.md)** – Documentation for the `RMT.m` class and `Fig_1_RMT_examples.m` script. Covers key equations from Harris et al. (2023) including sparse statistics, outlier eigenvalues, spectral radius, and Zero Row Sum (ZRS) conditions for controlling local eigenvalue outliers.

### StabilityAnalysisDocs/
Code architecture and usage guides for Figure 2 generation:

- **[Stability_Analysis_Code_Structure.md](docs/StabilityAnalysisDocs/Stability_Analysis_Code_Structure.md)** – Object-oriented architecture documentation for the three core classes: `SRNNModel` (simulation), `RMTMatrix` (connectivity construction), and `ParamSpaceAnalysis` (parameter sweeps). Includes state vector organization, Lyapunov method comparison, and complexity analysis.
- **[Script_Notes.md](docs/StabilityAnalysisDocs/Script_Notes.md)** – Practical guide for running Figure 2 scripts, including prerequisites, output locations, configuration options, and handling interrupted runs.

PDF versions of each markdown document are also available in their respective directories.