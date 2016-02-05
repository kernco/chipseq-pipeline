#!/bin/bash -l

#SBATCH -J chipseq-pipeline

module load python
module load cutadapt
module load trim-galore
module load bwa
module load java
module load picardtools
module load samtools

~/FAANG_pipelines/chipseq-pipeline/run_pipeline.sh $@
