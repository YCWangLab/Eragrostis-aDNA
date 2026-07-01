#!/bin/bash
# =============================================================================
# Pipeline Configuration
# Ancient DNA Analysis - Eragrostis pilosa (Xiaohe Cemetery)
# =============================================================================

# --- Directories ---
RAW_DIR="data/raw"
QC_DIR="data/qc"
ALIGN_DIR="data/align"
TAXON_DIR="data/taxonomy"
PLASTID_DIR="data/plastid"
PHYLO_DIR="data/phylogeny"
LOG_DIR="logs"

# --- Reference ---
ORGANELLE_DB="/maps/datasets/ref/organelle/hires-organelles"  # NCBI organelle database (Bowtie2 index)
ERAGROSTIS_REF="ref/NC_059738.1.fasta"      # Eragrostis pilosa plastid genome

# --- Sample ---
SAMPLE="YWL426"
R1="${RAW_DIR}/${SAMPLE}_R1.fastq.gz"
R2="${RAW_DIR}/${SAMPLE}_R2.fastq.gz"

# --- Threads ---
THREADS=16

# --- Tool versions (for reproducibility) ---
# fastp     v1.0.1
# seqkit    v2.12.0
# BBmap     (entropy filter)
# Bowtie2   v2.5.4
# ngsLCA    (Wang et al., 2022)
# BWA       v0.7.19
# mapDamage v2.2.2
# bcftools  v1.22
# MAFFT     v7.526
# IQ-TREE   v3.0.1

mkdir -p "$RAW_DIR" "$QC_DIR" "$ALIGN_DIR" "$TAXON_DIR" "$PLASTID_DIR" "$PHYLO_DIR" "$LOG_DIR"
