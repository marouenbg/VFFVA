==========
Changelog
==========

* :release:`0.5.0 <2026.03.31>`
* :feature:`-` Add GLPK as alternative solver backend (compile-time switch)
* :feature:`-` Add GitHub Actions CI with GLPK tests (replaces Travis CI)
* :feature:`-` Auto-detect macOS/Linux and ARM64/x86-64 in Makefile
* :feature:`-` Add solver parameter to MATLAB and Python wrappers
* :bug:`-` Fix CPLEX per-thread memory leak in FVA (env/lp never freed)
* :bug:`-` Fix GLPK thread safety: use MPI-only parallelism (GLPK not thread-safe)
* :bug:`-` Add GLPK simplex error and status checking
* :bug:`-` Fix OMP_SCHEDULE typo in MATLAB and Python wrappers
* :bug:`-` Fix scaling argument ignored when rxns file is also passed (C)
* :bug:`-` Fix bitwise OR used instead of logical OR in argument check (C)
* :bug:`-` Fix buffer overflow in model name handling (C)
* :bug:`-` Fix memory leaks for allocated arrays (C)
* :bug:`-` Fix mutable default argument and command injection in Python wrapper
* :bug:`-` Fix cleanup guard in MATLAB wrapper
* :bug:`-` Remove spurious double cast on CPXgetstat (C)
* :bug:`-` Fix import typo in README
* :release:`0.4.0 <2022.08.10>`
* :feature:`-` Support for Cv <= d constraints
* :release:`0.1.0 <2018.10.01>`
* :feature:`-` Changelog added to the doc
* :feature:`-` Improve the docs

