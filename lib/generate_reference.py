#!/usr/bin/env python3
"""Generate FVA reference CSV from a COBRA MATLAB model (.mat).

Loads the model with scipy (bypassing cobrapy's .mat loader which can
fail on older COBRA models with incompatible field types) and constructs
a cobra.Model for FVA.

Usage:
    python generate_reference.py <input.mat> <output.csv> [--optpct 90]
"""

import argparse
import csv
import warnings

import cobra
import numpy as np
import scipy.io as sio
import scipy.sparse as sp

warnings.filterwarnings("ignore")


def load_cobra_from_mat(mat_path):
    """Load a .mat file via scipy and build a cobra.Model."""
    mat = sio.loadmat(mat_path)
    # Find model struct
    model_key = None
    for k in mat:
        if k.startswith("__"):
            continue
        v = mat[k]
        if hasattr(v, "dtype") and v.dtype.names and "S" in v.dtype.names:
            model_key = k
            break
    if model_key is None:
        raise ValueError(f"No COBRA model found in {mat_path}")

    m = mat[model_key]
    S = m["S"][0, 0]
    if sp.issparse(S):
        S = S.tocsc()
    rxn_ids = [str(r[0]) for r in m["rxns"][0, 0].flatten()]
    met_ids = [str(r[0]) for r in m["mets"][0, 0].flatten()]
    lb = m["lb"][0, 0].flatten().astype(float)
    ub = m["ub"][0, 0].flatten().astype(float)
    c = m["c"][0, 0].flatten().astype(float)

    model = cobra.Model(model_key)
    metabolites = [cobra.Metabolite(mid) for mid in met_ids]

    reactions = []
    for j, rid in enumerate(rxn_ids):
        rxn = cobra.Reaction(rid)
        rxn.lower_bound = lb[j]
        rxn.upper_bound = ub[j]
        # Get column j of S
        if sp.issparse(S):
            col = S[:, j].toarray().flatten()
        else:
            col = S[:, j]
        stoich = {}
        for i in np.nonzero(col)[0]:
            stoich[metabolites[i]] = float(col[i])
        rxn.add_metabolites(stoich)
        reactions.append(rxn)

    model.add_reactions(reactions)

    # Set objective after reactions are in the model
    obj_idx = np.nonzero(c)[0]
    if len(obj_idx) > 0:
        model.objective = model.reactions[int(obj_idx[0])]
    return model


def main():
    parser = argparse.ArgumentParser(
        description="Generate FVA reference from COBRA .mat"
    )
    parser.add_argument("input", help="Input .mat file")
    parser.add_argument("output", help="Output reference CSV")
    parser.add_argument(
        "--optpct", type=int, default=90, help="Optimality percentage (default: 90)"
    )
    args = parser.parse_args()

    model = load_cobra_from_mat(args.input)
    fva = cobra.flux_analysis.flux_variability_analysis(
        model, fraction_of_optimum=args.optpct / 100.0, processes=1
    )
    # Reindex by model reaction order
    fva = fva.loc[[r.id for r in model.reactions]]

    with open(args.output, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["minFlux", "maxFlux"])
        for _, row in fva.iterrows():
            w.writerow([f'{row["minimum"]:.6f}', f'{row["maximum"]:.6f}'])

    print(f"Generated reference: {len(fva)} reactions -> {args.output}")


if __name__ == "__main__":
    main()
