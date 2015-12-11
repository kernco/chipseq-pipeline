$(MARK)_peaks.broadPeak : $(MARK).filtered.bam $(INPUT).filtered.bam
	macs2 callpeak -g 1.047e9 -q 0.05 -c $(INPUT).filtered.bam -t $(MARK).filtered.bam -f BAM -n $(MARK) -B --broad

$(MARK)_peaks.narrowPeak : $(MARK).filtered.bam $(INPUT).filtered.bam
	macs2 callpeak -g 1.047e9 -q 0.01 -c $(INPUT).filtered.bam -t $(MARK).filtered.bam -f BAM -n $(MARK) -B 

%.filtered.bam : %.duplicate-marked.bam
	samtools view -b -q 15 $< > $@

%.duplicate-marked.bam : %.sorted.bam
	java -jar $$PICARD/picard.jar MarkDuplicates INPUT=$< OUTPUT=$@ METRICS_FILE=output.dup_metrics REMOVE_DUPLICATES=false ASSUME_SORTED=true VALIDATION_STRINGENCY=SILENT

%.sorted.bam : %.aligned.bam
	java -jar $$PICARD/picard.jar SortSam INPUT=$< OUTPUT=$@ SORT_ORDER=coordinate VALIDATION_STRINGENCY=SILENT

%.aligned.bam : %.paired.bam %.unpaired.bam
	samtools merge $@ $*.paired.bam $*.unpaired.bam

%.paired.bam : %.R1.paired.sai %.R2.paired.sai
	bwa sampe $(ASSEMBLY) $*.R1.paired.sai $*.R2.paired.sai $*.R1.paired.fastq.gz $*.R2.paired.fastq.gz | samtools view -bS - > $@

%.unpaired.bam : %.R1.unpaired.sai %.R2.unpaired.sai
	bwa samse $(ASSEMBLY) $*.R1.unpaired.sai $*.R1.unpaired.fastq.gz | samtools view -bS - > $@
	bwa samse $(ASSMEBLY) $*.R2.unpaired.sai $*.R2.unpaired.fastq.gz | samtools view -bS - >> $@

%.sai : %.fastq.gz
	bwa aln -q 15 -t 8 $(ASSEMBLY) $< > $@

%.R1.paired.fastq.gz %.R1.unpaired.fastq.gz %.R2.paired.fastq.gz %.R2.unpaired.fastq.gz : %.R1.fastq.gz %.R2.fastq.gz
	java -jar /home/ckern/Trimmomatic-0.33/trimmomatic.jar PE -phred33 $*.R1.fastq.gz $*.R2.fastq.gz $*.R1.paired.fastq.gz $*.R1.unpaired.fastq.gz $*.R2.paired.fastq.gz $*.R2.unpaired.fastq.gz ILLUMINACLIP:/home/ckern/Trimmomatic-0.33/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
