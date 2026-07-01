# Ancient DNA Pipeline — *Eragrostis pilosa* (Xiaohe Cemetery)

Bioinformatics pipeline for ancient DNA analysis of *Eragrostis pilosa* caryopses recovered from the Xiaohe Cemetery, Xinjiang, China (~3270 ± 25 BP).

## Pipeline Overview

```
Raw reads (Illumina NovaSeq 5000, PE150)
    │
    ▼
01_qc.sh              — fastp → seqkit rmdup → BBmap (entropy filter)
    │
    ▼
02_taxonomy.sh        — Bowtie2 (NCBI organelle DB) → ngsLCA
    │
    ▼
03_plastid_reconstruction.sh  — BWA aln → mapDamage → bcftools consensus
    │
    ▼
04_phylogeny.sh       — MAFFT → IQ-TREE (ML + NJ, 1000 bootstrap)
```

## Dependencies

| Tool       | Version  | Reference |
|------------|----------|-----------|
| fastp      | v1.0.1   | Chen, 2025 |
| seqkit     | v2.12.0  | Shen et al., 2016 |
| BBmap      | —        | Bushnell, BBTools |
| Bowtie2    | v2.5.4   | Langdon, 2015 |
| ngsLCA     | —        | Wang et al., 2022 |
| BWA        | v0.7.19  | Li & Durbin, 2009 |
| mapDamage  | v2.2.2   | Jónsson et al., 2013 |
| samtools   | —        | — |
| bcftools   | v1.22    | Danecek et al., 2021 |
| MAFFT      | v7.526   | Katoh & Standley, 2014 |
| IQ-TREE    | v3.0.1   | Wong et al., 2025 |

## Reference Sequences

- *Eragrostis pilosa* plastid genome: [NC_059738.1](https://www.ncbi.nlm.nih.gov/nuccore/NC_059738.1)
- NCBI organelle database: download via `wget` from NCBI FTP
- Outgroup: *Uniola paniculata*

## Usage

```bash
# Configure paths in 00_config.sh first, then:

# Run full pipeline
bash run_all.sh

# Run individual steps
bash run_all.sh qc
bash run_all.sh taxon
bash run_all.sh plastid
bash run_all.sh phylo
```

## Directory Structure

```
.
├── 00_config.sh
├── 01_qc.sh
├── 02_taxonomy.sh
├── 03_plastid_reconstruction.sh
├── 04_phylogeny.sh
├── run_all.sh
├── data/
│   ├── raw/          # raw FASTQ files
│   ├── qc/           # quality-filtered reads
│   ├── align/        # BAM alignments
│   ├── taxonomy/     # ngsLCA output
│   ├── plastid/      # consensus genome + mapDamage
│   └── phylogeny/    # alignment + trees
├── ref/
│   ├── NC_059738.1.fasta
│   ├── ncbi_organelle/   # Bowtie2 index
│   └── taxonomy/         # nodes.dmp, names.dmp
└── logs/
```

## Tree Visualization

Upload `.treefile` outputs from `data/phylogeny/` to [iTOL](https://itol.embl.de/) for interactive visualization.
