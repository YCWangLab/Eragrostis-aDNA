#!/bin/bash
# =============================================================================
# Master Pipeline - Ancient DNA Analysis of Eragrostis pilosa
# Xiaohe Cemetery, Xinjiang, China (~3270 BP)
# =============================================================================
# Usage: bash run_all.sh [step]
#   bash run_all.sh        # run all steps
#   bash run_all.sh qc     # run step 1 only
#   bash run_all.sh taxon  # run step 2 only
#   bash run_all.sh plastid # run step 3 only
#   bash run_all.sh phylo  # run step 4 only

set -euo pipefail

STEP="${1:-all}"

run_step() {
    local name="$1"
    local script="$2"
    echo ""
    echo "============================================="
    echo " Running: ${name}"
    echo "============================================="
    bash "${script}"
}

case "$STEP" in
    all)
        run_step "Step 1: Quality Control"             01_qc.sh
        run_step "Step 2: Taxonomic Classification"    02_taxonomy.sh
        run_step "Step 3: Plastid Reconstruction"      03_plastid_reconstruction.sh
        run_step "Step 4: Phylogenetic Analysis"       04_phylogeny.sh
        ;;
    qc)      run_step "Step 1: Quality Control"             01_qc.sh ;;
    taxon)   run_step "Step 2: Taxonomic Classification"    02_taxonomy.sh ;;
    plastid) run_step "Step 3: Plastid Reconstruction"      03_plastid_reconstruction.sh ;;
    phylo)   run_step "Step 4: Phylogenetic Analysis"       04_phylogeny.sh ;;
    *)
        echo "Unknown step: $STEP"
        echo "Usage: bash run_all.sh [all|qc|taxon|plastid|phylo]"
        exit 1
        ;;
esac

echo ""
echo "Pipeline finished: $(date)"
