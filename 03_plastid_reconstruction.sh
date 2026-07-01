#!/bin/bash
# =============================================================================
# Step 3: Plastid Genome Reconstruction
# Tools: BWA aln, mapDamage, samtools, bcftools
# Reference: Eragrostis pilosa NC_059738.1
# =============================================================================

source 00_config.sh

echo "[$(date)] Starting plastid genome reconstruction: ${SAMPLE}"

# --- 3a. Index reference (run once) ---
if [ ! -f "${ERAGROSTIS_REF}.bwt" ]; then
    bwa index "${ERAGROSTIS_REF}"
    echo "[$(date)] Reference indexed."
fi

# --- 3b. Align with BWA aln (seeding disabled for aDNA short reads) ---
bwa aln \
    -l 1000 \
    -t "${THREADS}" \
    "${ERAGROSTIS_REF}" \
    "${QC_DIR}/${SAMPLE}_clean_R1.fastq.gz" \
    > "${ALIGN_DIR}/${SAMPLE}_R1.sai" \
    2> "${LOG_DIR}/03a_bwa_aln_R1.log"

bwa aln \
    -l 1000 \
    -t "${THREADS}" \
    "${ERAGROSTIS_REF}" \
    "${QC_DIR}/${SAMPLE}_clean_R2.fastq.gz" \
    > "${ALIGN_DIR}/${SAMPLE}_R2.sai" \
    2> "${LOG_DIR}/03a_bwa_aln_R2.log"

bwa sampe \
    "${ERAGROSTIS_REF}" \
    "${ALIGN_DIR}/${SAMPLE}_R1.sai" \
    "${ALIGN_DIR}/${SAMPLE}_R2.sai" \
    "${QC_DIR}/${SAMPLE}_clean_R1.fastq.gz" \
    "${QC_DIR}/${SAMPLE}_clean_R2.fastq.gz" \
    > "${ALIGN_DIR}/${SAMPLE}_raw.sam" \
    2> "${LOG_DIR}/03a_bwa_sampe.log"

echo "[$(date)] BWA alignment done."

# --- 3c. Sort and index BAM ---
samtools view -bS -F 4 "${ALIGN_DIR}/${SAMPLE}_raw.sam" \
    | samtools sort -@ "${THREADS}" \
    -o "${ALIGN_DIR}/${SAMPLE}_sorted.bam"
samtools index "${ALIGN_DIR}/${SAMPLE}_sorted.bam"

rm "${ALIGN_DIR}/${SAMPLE}_raw.sam" \
   "${ALIGN_DIR}/${SAMPLE}_R1.sai" \
   "${ALIGN_DIR}/${SAMPLE}_R2.sai"

# --- 3d. DNA damage authentication (mapDamage) ---
mapDamage \
    -i "${ALIGN_DIR}/${SAMPLE}_sorted.bam" \
    -r "${ERAGROSTIS_REF}" \
    -d "${PLASTID_DIR}/mapDamage_${SAMPLE}" \
    --no-rescale \
    2> "${LOG_DIR}/03b_mapDamage.log"

echo "[$(date)] mapDamage done. Results: ${PLASTID_DIR}/mapDamage_${SAMPLE}/"

# --- 3e. Filter by mapping quality (MAPQ >= 30) ---
samtools view -bq 30 \
    "${ALIGN_DIR}/${SAMPLE}_sorted.bam" \
    -o "${ALIGN_DIR}/${SAMPLE}_mapq30.bam"
samtools index "${ALIGN_DIR}/${SAMPLE}_mapq30.bam"

echo "[$(date)] MAPQ>=30 filtering done."

# --- 3f. Generate consensus sequence (bcftools) ---
bcftools mpileup \
    -f "${ERAGROSTIS_REF}" \
    "${ALIGN_DIR}/${SAMPLE}_mapq30.bam" \
    | bcftools call \
        --consensus-caller \
        --variants-only \
        -o "${PLASTID_DIR}/${SAMPLE}_variants.vcf.gz" \
        -Oz
bcftools index "${PLASTID_DIR}/${SAMPLE}_variants.vcf.gz"

bcftools consensus \
    -f "${ERAGROSTIS_REF}" \
    "${PLASTID_DIR}/${SAMPLE}_variants.vcf.gz" \
    -o "${PLASTID_DIR}/${SAMPLE}_consensus.fasta"

# Rename FASTA header
sed -i "s/^>.*$/>${SAMPLE}_ancient/" "${PLASTID_DIR}/${SAMPLE}_consensus.fasta"

echo "[$(date)] Consensus genome written: ${PLASTID_DIR}/${SAMPLE}_consensus.fasta"
