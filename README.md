# *Charina bottae* Genome Assembly

This repository documents the genome assembly workflow for *Charina bottae* (Rubber boa) using:

- PacBio HiFi long reads for de novo genome assembly
- Dovetail/Omni-C paired-end reads for scaffolding
- NIH Biowulf for data storage / analysis
- GitHub for scripts / documentation

> **Note:** Raw sequencing data are stored on Biowulf and are not committed to this repository.

Analyses are performed on the NIH Biowulf computing cluster.

Project directory:

```text
/data/Wilson_Lab/projects/Group_Genome_Assembly/Charina_bottae/
```

## Project tasks

- Retrieve sequencing data from public repositories
- Assemble PacBio HiFi long reads
- Retrieve and prepare Dovetail/Omni-C paired-end reads for scaffolding
- Evaluate assembly quality
- Scaffold the assembly using Dovetail/Omni-C data


## Species information

**Species:** *Charina bottae*  
**Common name:** Rubber boa  
**BioProject:**  [PRJNA824832](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA824832)  
**Biosample:** SAMN26367999

---
## Sequencing data

Sequencing data were identified through the NCBI BioProject and Sequence Read Archive (SRA).

Three SRA runs are used for this project, including two paired-end SRA runs for Dovetail/omni-c data.

| SRA run | Sequencing data | Download size | Bases | Purpose |
|---|---|---:|---:|---|
| SRR19599927 | Dovetail Omni-C | 5.1 GB | 15.4 Gb | Genome scaffolding |
| SRR19599928 | Dovetail Omni-C | 7.3 GB | 21.9 Gb | Genome scaffolding |
| SRR19599929 | PacBio HiFi | 35 GB | 54.2 Gb | De novo genome assembly |

The two Dovetail Omni-C runs represent the same library and sample and are combined for downstream scaffolding.

---

### Downloading the SRA runs
Because downloading and processing the sequencing data takes several hours, the download was submitted as a Slurm job:

```bash
sbatch download_reads.sh
```

The script is included in this repository and is also located on Biowulf at:

```text
/data/Wilson_Lab/projects/Group_Genome_Assembly/Charina_bottae/raw_reads
```

The SRA Toolkit module used on Biowulf was:

```bash
module load sratoolkit/3.4.0
```

This Biowulf module requires local scratch space, so jobs were run with `/lscratch.

SRA runs were retrieved with prefetch

Each dovetail/omni-c run was then converted into paired-end FASTQ files using `fasterq-dump`.


Final files:

```text
SRR19599927_R1.fastq.gz
SRR19599927_R2.fastq.gz
SRR19599928_R1.fastq.gz
SRR19599928_R2.fastq.gz
SRR19599929.fastq.gz
```

---


## Read-count validation + Concat

| SRA run | R1 reads | R2 reads |
|---|---:|---:|
| SRR19599927 | 51,125,626 | 51,125,626 |
| SRR19599928 | 72,389,234 | 72,389,234 |


Combining Dovetail / Omni-C runs

These were two runs of the same library for the same sample. The two SRA runs were combined so that scaffolding can be done with a single R1 file and a single R2 file.


R1 files were concatenated with:

```bash
cat \
    SRR19599927_R1.fastq.gz \
    SRR19599928_R1.fastq.gz \
    > Charina_combined_R1.fastq.gz
```

R2 files were concatenated with:

```bash
cat \
    SRR19599927_R2.fastq.gz \
    SRR19599928_R2.fastq.gz \
    > Charina_combined_R2.fastq.gz
```

Each combined file contains:

```text
123,514,860 reads
```

The original SRA-specific FASTQ files are being retained for now.

---

## Directory structure

Current project organization:

```text
Charina_bottae/
├── raw_reads/
│   ├── SRR19599927_R1.fastq.gz
│   ├── SRR19599927_R2.fastq.gz
│   ├── SRR19599928_R1.fastq.gz
│   ├── SRR19599928_R2.fastq.gz
│   ├── SRR19599929.fastq.gz
│   ├── Charina_combined_R1.fastq.gz
│   └── Charina_combined_R2.fastq.gz
└── README.md
```
---

## Next steps

- Perform QC of the PacBio HiFi and Omni-C short read data
- Perform long-read genome assembly
- Evaluate assembly quality
- Use the combined Dovetail/Omni-C reads for scaffolding
- Evaluate the scaffolded assembly
- Document software, parameters, and outputs for each stage
