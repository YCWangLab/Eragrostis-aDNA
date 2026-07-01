#!/bin/bash
# =============================================================================
# Step 2: Taxonomic Classification
# Tools: Bowtie2, ngsLCA
# Reference: NCBI organelle database
# =============================================================================

source 00_config.sh

echo "[$(date)] Starting taxonomic classification: ${SAMPLE}"

# --- 2a. Align to NCBI organelle database (Bowtie2) ---
bowtie2 \
    -x "${ORGANELLE_DB}" \
    -1 "${QC_DIR}/${SAMPLE}_clean_R1.fastq.gz" \
    -2 "${QC_DIR}/${SAMPLE}_clean_R2.fastq.gz" \
    -k 10 \
    -L 22 \
    -i S,1,1.15 \
    --mp 1,1 \
    --rdg 0,1 \
    --rfg 0,1 \
    --score-min L,0,-0.1 \
    --no-unal \
    --threads "${THREADS}" \
    -S "${TAXON_DIR}/${SAMPLE}_organelle.sam" \
    2> "${LOG_DIR}/02a_bowtie2.log"

echo "[$(date)] Bowtie2 alignment done."

# --- 2b. Convert to sorted BAM ---
samtools view -bS "${TAXON_DIR}/${SAMPLE}_organelle.sam" \
    | samtools sort -@ "${THREADS}" \
    -o "${TAXON_DIR}/${SAMPLE}_organelle_sorted.bam"
samtools index "${TAXON_DIR}/${SAMPLE}_organelle_sorted.bam"

rm "${TAXON_DIR}/${SAMPLE}_organelle.sam"

# --- 2c. Taxonomic assignment with ngsLCA ---
# Edit distance = 0 for high-confidence classification
# Requires a nodes.dmp / names.dmp from NCBI taxonomy
ngsLCA \
    -bam "${TAXON_DIR}/${SAMPLE}_organelle_sorted.bam" \
    -editdistance 0 \
    -nodes ref/taxonomy/nodes.dmp \
    -names ref/taxonomy/names.dmp \
    -out "${TAXON_DIR}/${SAMPLE}_ngsLCA" \
    2> "${LOG_DIR}/02b_ngsLCA.log"

echo "[$(date)] Taxonomic classification complete. Output: ${TAXON_DIR}/${SAMPLE}_ngsLCA*"
