#!/bin/bash
# =============================================================================
# Step 4: Phylogenetic Analysis
# Tools: MAFFT, IQ-TREE, (NJ via MEGA or IQ-TREE)
# Outgroup: Uniola paniculata
# Visualization: iTOL (https://itol.embl.de/)
# =============================================================================

source 00_config.sh

echo "[$(date)] Starting phylogenetic analysis."

# --- Input: combined FASTA of ancient + extant Eragrostis plastid genomes ---
# Prepare a file listing all plastid genomes (ancient + extant + outgroup)
# Expected: ${PHYLO_DIR}/all_plastids_raw.fasta
COMBINED="${PHYLO_DIR}/all_plastids_raw.fasta"
ALIGNED="${PHYLO_DIR}/all_plastids_aligned.fasta"
TRIMMED="${PHYLO_DIR}/all_plastids_trimmed.fasta"

# Append ancient consensus to the combined file
cat "${PLASTID_DIR}/${SAMPLE}_consensus.fasta" >> "${COMBINED}"

# --- 4a. Multiple sequence alignment (MAFFT) ---
mafft \
    --auto \
    --thread "${THREADS}" \
    "${COMBINED}" \
    > "${ALIGNED}" \
    2> "${LOG_DIR}/04a_mafft.log"

echo "[$(date)] MAFFT alignment done."

# --- 4b. (Optional) Trim alignment with trimAl ---
# trimal -in "${ALIGNED}" -out "${TRIMMED}" -automated1
# If skipping trimming, use aligned file directly:
cp "${ALIGNED}" "${TRIMMED}"

# --- 4c. Maximum Likelihood tree (IQ-TREE) ---
# ModelFinder selects best substitution model automatically
iqtree3 \
    -s "${TRIMMED}" \
    -m MFP \
    -B 1000 \
    -T "${THREADS}" \
    --outgroup "Uniola_paniculata" \
    --prefix "${PHYLO_DIR}/ML_tree" \
    2> "${LOG_DIR}/04b_iqtree_ML.log"

echo "[$(date)] IQ-TREE ML analysis done."

# --- 4d. Neighbor-Joining tree (IQ-TREE with -te NJ) ---
iqtree3 \
    -s "${TRIMMED}" \
    -te NJ \
    -B 1000 \
    -T "${THREADS}" \
    --outgroup "Uniola_paniculata" \
    --prefix "${PHYLO_DIR}/NJ_tree" \
    2> "${LOG_DIR}/04c_iqtree_NJ.log"

echo "[$(date)] IQ-TREE NJ analysis done."
echo ""
echo "Results:"
echo "  ML tree : ${PHYLO_DIR}/ML_tree.treefile"
echo "  NJ tree : ${PHYLO_DIR}/NJ_tree.treefile"
echo ""
echo "Upload .treefile to iTOL (https://itol.embl.de/) for visualization."
