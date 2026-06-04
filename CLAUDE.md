# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

MATLAB code accompanying the paper *"Adaptation modulates effective connectivity and network stability"* (Richner, Dervinis, Lundstrom). It is a **fixed snapshot** consolidating subsets of two upstream repos (`RandomMatrixTheory`, `FractionalReservoir`) and exists to reproduce Figure 1 and Figure 2 of the manuscript. Treat the published code paths and outputs as the reproducibility contract — do not refactor file layout, rename scripts, or alter numerical recipes without explicit user instruction.

## Running figures

Everything is orchestrated from the project root in MATLAB:

```matlab
run_all_figures.m            % master: setup paths once, run all figure scripts with pauses
```

The master script defines `master_save_figs` (`'save_all_figs'` / `'save_no_figs'` / `'follow_scripts_save_figs'`) which overrides each child script's `save_figs` flag.

Individual scripts can also be run standalone — each calls `setup_paths()` internally. The two Figure 2 scripts have top-of-file `save_figs` and `save_workspace` flags.

| Script | Output |
|---|---|
| `RandomMatrixTheory/Fig_1_RMT_examples.m` | Figure 1 (eigenvalue spectra) |
| `StabilityAnalysis/scripts/Fig_2_single_vs_dual_adaptation_example.m` | Figure 2a–f (SFA-only vs SFA+STD time series on identical W and stimulus, controlled by `rng_seeds = [42 42]`) |
| `StabilityAnalysis/scripts/Fig_2_fraction_excitatory_analysis.m` | Figure 2g+ (parameter sweep over E fraction × 4 adaptation conditions; ~25 min serial, faster with Parallel Computing Toolbox) |
| `StabilityAnalysis/scripts/Fig_2_fraction_excitatory_load_and_plot.m` | Re-plot + re-stat from a saved PSA output dir (no re-simulation) |
| `Sompolinsky_N_*.m` | Sompolinsky 1988 demos (adaptation off, tanh activation) as special cases of `SRNNModel` |

If `Fig_2_fraction_excitatory_analysis.m` is interrupted, partial batches in `temp_batches/` can be merged for plotting via `psa = ParamSpaceAnalysis(); psa.output_dir = '...'; psa.consolidate();` — this does **not** resume computation.

## Path setup

`StabilityAnalysis/scripts/setup_paths.m` adds `StabilityAnalysis/src/` and its subdirs to the MATLAB path. Figure 2 scripts call it automatically; only call it manually if running individual `src/` functions interactively.

## Architecture (Figure 2 codebase)

Three OO classes in `StabilityAnalysis/src/` do all the work. The full reference is `docs/StabilityAnalysisDocs/Stability_Analysis_Code_Structure.md` — read that before touching the simulation core.

- **`SRNNModel`** — main simulation. Pattern is `model = SRNNModel(...); model.build(); model.run(); model.plot();`. Integrates the SRNN ODEs (dendritic state `x`, SFA `a` with multiple timescales, STD `b`) via a packed state vector `S = [a_E(:); a_I(:); b_E(:); b_I(:); x(:)]`. Static `dynamics_fast(t, S, params)` is the RHS. The `lya_method` property selects `'benettin'` (LLE only, default, scales O(N)), `'qr'` (full spectrum, O(N³) — avoid for N_states > ~200), or `'none'`.
- **`RMTMatrix`** — sparse connectivity following Harris et al. 2023 RMT, with Dale's law (separate E/I means and variances) and optional zero-row-sum modes (`zrs_mode`). Constructed lazily: accessing `rmt.W` triggers build.
- **`ParamSpaceAnalysis`** — multi-dimensional gridded sweeps. `add_grid_parameter(name, values)` has two modes: a 1×2 `[min max]` is expanded via `linspace(..., n_levels)`; a 3+-element vector is used verbatim. By default sweeps run across **four adaptation conditions** (`no_adaptation`, `sfa_only`, `std_only`, `sfa_and_std`) using the **same W per grid point** for fair comparison. Uses `parfor` + checkpointed batches; randomized execution order so early stopping is representative.

PSA results land in `StabilityAnalysis/data/param_space/<note>_nLevs_<N>_<timestamp>/` with per-condition `.mat` files plus `psa_object.mat`. Figures land in `StabilityAnalysis/figs/...`.

## Conventions

- **`.mat`, `.fig`, `.svg` are gitignored** (too large). PNG/JPEG outputs are intentionally allowed because they ship with the manuscript. Do not commit large binary regenerations.
- **Reproducibility-critical**: RNG seeds, parameter defaults, and `dynamics_fast` math are part of the published artifact. Changes that alter numerical output must be flagged to the user.
- **Docs are part of the artifact too**: `docs/` contains markdown + PDF derivations (parameter table, J_eff derivation, system equations, RMT notes, code structure). PDFs are regenerated via `docs/convert_md_docs_to_pdf.sh`. Keep markdown and PDF in sync when editing.
- **MATLAB MCP available**: prefer `mcp__matlab__evaluate_matlab_code` / `mcp__matlab__run_matlab_file` / `mcp__matlab__check_matlab_code` over shelling out — the user has a visible MATLAB session and graphical output appears in the MATLAB UI. Launch MATLAB first via `/launch-matlab` if not already connected.
