#!/bin/bash
# =============================================================================
# Step 1: Quality Control
# Tools: fastp, seqkit, BBmap
# =============================================================================

source 00_config.sh

echo "[$(date)] Starting QC for sample: ${SAMPLE}"

# --- 1a. Adapter trimming, quality filtering, duplicate removal (fastp) ---
fastp \
    --in1 "${R1}" \
    --in2 "${R2}" \
    --out1 "${QC_DIR}/${SAMPLE}_fastp_R1.fastq.gz" \
    --out2 "${QC_DIR}/${SAMPLE}_fastp_R2.fastq.gz" \
    --length_required 30 \
    --low_complexity_filter \
    --complexity_threshold 30 \
    --dedup \
    --thread "${THREADS}" \
    --json "${QC_DIR}/${SAMPLE}_fastp.json" \
    --html "${QC_DIR}/${SAMPLE}_fastp.html" \
    2> "${LOG_DIR}/01a_fastp.log"

echo "[$(date)] fastp done."

# --- 1b. Remove sequence-level duplicates (seqkit rmdup) ---
seqkit rmdup \
    --by-seq \
    "${QC_DIR}/${SAMPLE}_fastp_R1.fastq.gz" \
    -o "${QC_DIR}/${SAMPLE}_seqkit_R1.fastq.gz" \
    2> "${LOG_DIR}/01b_seqkit_R1.log"

seqkit rmdup \
    --by-seq \
    "${QC_DIR}/${SAMPLE}_fastp_R2.fastq.gz" \
    -o "${QC_DIR}/${SAMPLE}_seqkit_R2.fastq.gz" \
    2> "${LOG_DIR}/01b_seqkit_R2.log"

echo "[$(date)] seqkit rmdup done."

# --- 1c. Low-complexity filtering (BBmap bbduk) ---
bbduk.sh \
    in="${QC_DIR}/${SAMPLE}_seqkit_R1.fastq.gz" \
    in2="${QC_DIR}/${SAMPLE}_seqkit_R2.fastq.gz" \
    out="${QC_DIR}/${SAMPLE}_clean_R1.fastq.gz" \
    out2="${QC_DIR}/${SAMPLE}_clean_R2.fastq.gz" \
    entropy=0.7 \
    minlen=30 \
    threads="${THREADS}" \
    2> "${LOG_DIR}/01c_bbduk.log"

echo "[$(date)] QC complete. Output: ${QC_DIR}/${SAMPLE}_clean_R*.fastq.gz"
