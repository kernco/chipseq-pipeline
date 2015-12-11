The file chipseq.makefile can be used with the make program to trim, align,
filter and peak call ChIP-seq libraries. In the same directory as the raw
sequencing reads, execute the command:

$ make -f chipseq.makefile MARK=H3K4me3 INPUT=input ASSEMBLY=assembly.fa

The MARK variable is the base file name for the raw reads of the histone
modification libraries. In the example above, the program will expect two
files, H3K4me3.R1.fastq.gz and H3K4me3.R2.fastq.gz, to exist in the directory.
Similarly, the INPUT variable is the base name for the control/input DNA
reads. The files input.R1.fastq.gz and input.R2.fastq.gz are expected in
the example. Finally, the ASSEMBLY variable is a path to a fasta file
containing the sequences of the genome the reads should be aligned to. This
file does not need to be in the same directory as long as the full path to
it is specified.

In the makefile's current state, the following commands are expected to
be available: bwa, samtools, macs2, java. Also, the environmental variable
$PICARD should be set so that $PICARD/picard.jar properly references the
Picard tools program. Trimmomatic should also be installed, see below.

A few modifications should be made to this makefile before running on your
own data. First, the Trimmomatic command on line 30 needs to be modified
so that the paths to the jar file and the adapter sequences match your
own system. The macs2 commands on lines 2 and 5 have a -g argument which
should be changed to match the size of your target genome (it is currently
configured for the chicken genome).
