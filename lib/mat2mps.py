#!/usr/bin/env python3
"""Convert a COBRA MATLAB model (.mat) to MPS format for VFFVA.

Usage:
    python mat2mps.py <input.mat> <output.mps> [--model-key KEY]

Reads the stoichiometric matrix S, bounds (lb, ub), and objective (c)
from a COBRA-format .mat file and writes a fixed-format MPS file
compatible with CPLEX and GLPK.
"""

import argparse
import sys

import numpy as np
import scipy.io as sio
import scipy.sparse as sp


def load_cobra_model(mat_path, model_key=None):
    """Load S, lb, ub, c from a COBRA MATLAB .mat file."""
    mat = sio.loadmat(mat_path)
    # Auto-detect model key
    if model_key is None:
        candidates = [k for k in mat if not k.startswith("__")]
        # Look for struct with 'S' field
        for k in candidates:
            v = mat[k]
            if hasattr(v, "dtype") and v.dtype.names and "S" in v.dtype.names:
                model_key = k
                break
        if model_key is None:
            raise ValueError(
                f"No COBRA model found. Keys: {candidates}"
            )
    model = mat[model_key]
    S = model["S"][0, 0]
    if sp.issparse(S):
        S = S.tocsc()
    lb = model["lb"][0, 0].flatten().astype(float)
    ub = model["ub"][0, 0].flatten().astype(float)
    c = model["c"][0, 0].flatten().astype(float)
    return S, lb, ub, c


def write_mps(S, lb, ub, c, out_path, name="MODEL"):
    """Write an MPS file from S, lb, ub, c."""
    m, n = S.shape
    name_trunc = name[:8]

    with open(out_path, "w") as f:
        # NAME
        f.write(f"NAME          {name_trunc:<14s}\n")

        # ROWS
        f.write("ROWS\n")
        f.write(" N  COST\n")
        for i in range(1, m + 1):
            f.write(f" E  EQ{i}\n")

        # COLUMNS - two entries per line like BuildMPS
        f.write("COLUMNS\n")
        if sp.issparse(S):
            S_csc = S.tocsc()
        else:
            S_csc = sp.csc_matrix(S)

        for j in range(n):
            col_name = f"X{j + 1}"
            entries = []
            # Objective coefficient
            if c[j] != 0.0:
                entries.append(("COST", c[j]))
            # S matrix entries
            col_start = S_csc.indptr[j]
            col_end = S_csc.indptr[j + 1]
            for idx in range(col_start, col_end):
                row = S_csc.indices[idx]
                val = S_csc.data[idx]
                if val != 0.0:
                    entries.append((f"EQ{row + 1}", val))

            # Write two entries per line
            for k in range(0, len(entries), 2):
                row1, val1 = entries[k]
                line = f"    {col_name:<10s}{row1:<10s}{_fmt_val(val1):<14s}"
                if k + 1 < len(entries):
                    row2, val2 = entries[k + 1]
                    line += f"{row2:<10s}{_fmt_val(val2):<14s}"
                f.write(line.rstrip() + "\n")

        # RHS (all zeros for Sv=0, omit)
        f.write("RHS\n")

        # BOUNDS
        f.write("BOUNDS\n")
        for j in range(n):
            col_name = f"X{j + 1}"
            lo, up = lb[j], ub[j]
            # MPS default is 0 <= x < +inf
            # Only write LO if != 0
            if lo != 0.0:
                f.write(f" LO BND1      {col_name:<10s}{_fmt_val(lo)}\n")
            if not np.isinf(up):
                f.write(f" UP BND1      {col_name:<10s}{_fmt_val(up)}\n")

        f.write("ENDATA\n")


def _fmt_val(v):
    """Format a numeric value for MPS (integer-like values without decimal)."""
    if v == int(v):
        return str(int(v))
    # Use enough precision but avoid excessive trailing zeros
    return f"{v:.6g}"


def main():
    parser = argparse.ArgumentParser(description="Convert COBRA .mat to MPS")
    parser.add_argument("input", help="Input .mat file")
    parser.add_argument("output", help="Output .mps file")
    parser.add_argument("--model-key", default=None, help="Key in .mat file")
    parser.add_argument("--name", default=None, help="Problem name (default: from filename)")
    args = parser.parse_args()

    S, lb, ub, c = load_cobra_model(args.input, args.model_key)
    name = args.name or args.output.rsplit("/", 1)[-1].replace(".mps", "")
    write_mps(S, lb, ub, c, args.output, name=name)
    print(f"Wrote {args.output}: {S.shape[0]} rows, {S.shape[1]} cols")


if __name__ == "__main__":
    main()
