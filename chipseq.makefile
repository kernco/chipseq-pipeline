all: $(MARK)_peaks.broadPeak $(MARK)_peaks.narrowPeak

.SECONDARY: 

$(MARK)_broad_report.txt : $(MARK)_peaks.broadPeak $(MARK).filtered.bam $(MARK).deduped.bam $(MARK).aligned.bam $(MARK)_trimmed.fq.gz
	echo "Raw reads" > $@
	echo `zcat $(MARK).fq.gz | wc -l` / 4 | bc >> $@
	echo "Trimmed reads" >> $@
	echo `zcat $(MARK)_trimmed.fq.gz | wc -l` / 4 | bc >> $@
	echo "Aligned reads" >> $@
	samtools view -c $(MARK).aligned.bam >> $@
	echo "Duplicate alignments removed" >> $@
	samtools view -c $(MARK).deduped.bam >> $@
	echo "Filtered alignments" >> $@
	samtools view -c $(MARK).filtered.bam >> $@
	echo "Peaks called" >> $@
	cat $(MARK)_peaks.broadPeak | wc -l >> $@

$(MARK)_narrow_report.txt : $(MARK)_peaks.narrowPeak $(MARK).filtered.bam $(MARK).deduped.bam $(MARK).aligned.bam $(MARK)_trimmed.fq.gz
	echo "Raw reads" > $@
	echo `zcat $(MARK).fq.gz | wc -l` / 4 | bc >> $@
	echo "Trimmed reads" >> $@
	echo `zcat $(MARK)_trimmed.fq.gz | wc -l` / 4 | bc >> $@
	echo "Aligned reads" >> $@
	samtools view -c $(MARK).aligned.bam >> $@
	echo "Duplicate alignments removed" >> $@
	samtools view -c $(MARK).deduped.bam >> $@
	echo "Filtered alignments" >> $@
	samtools view -c $(MARK).filtered.bam >> $@
	echo "Peaks called" >> $@
	cat $(MARK)_peaks.narrowPeak | wc -l >> $@
	
$(MARK)_peaks.broadPeak : $(MARK).filtered.bam $(INPUT).filtered.bam
	macs2 callpeak -g $(GSIZE) -q 0.05 -c $(INPUT).filtered.bam -t $(MARK).filtered.bam -f BAM -n $(MARK) -B --broad

$(MARK)_peaks.narrowPeak : $(MARK).filtered.bam $(INPUT).filtered.bam
	macs2 callpeak -g $(GSIZE) -q 0.01 -c $(INPUT).filtered.bam -t $(MARK).filtered.bam -f BAM -n $(MARK) -B 

%.filtered.bam : %.deduped.bam
	samtools view -b -q 15 $< > $@

%.deduped.bam : %.sorted.bam
	picard-tools MarkDuplicates INPUT=$< OUTPUT=$@ METRICS_FILE=output.dup_metrics REMOVE_DUPLICATES=false ASSUME_SORTED=true VALIDATION_STRINGENCY=SILENT

%.sorted.bam : %.aligned.bam
	picard-tools SortSam INPUT=$< OUTPUT=$@ SORT_ORDER=coordinate VALIDATION_STRINGENCY=SILENT

%.aligned.bam : %.sai
	bwa samse $(ASSEMBLY) $< $*.fq.gz | samtools view -bS - > $@

%.sai : %_trimmed.fq.gz
	bwa aln -q 15 -t 8 $(ASSEMBLY) $< > $@

%_trimmed.fq.gz: %.fq.gz
	trim_galore $<
