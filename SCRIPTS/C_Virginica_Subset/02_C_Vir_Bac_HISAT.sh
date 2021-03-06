#!/bin/bash
#PBS-l nodes=2
#PBS-l walltime=1000:00:00
#PBS -j oe
#PBS -q default
#PBS -o out_C_VIR_Bac_HISAT
#PBS -e err_C_VIR_Bac_HISAT
#PBS -m ae -M erin_roberts@my.uri.edu

set -e
echo "START" $(date)

module load HISAT2/2.0.4-foss-2016b   
module load SAMtools/1.3.1-foss-2016b
cd /data3/marine_diseases_lab/erin/Bio_project_SRA/pipeline_files/C_Vir_subset
F=/data3/marine_diseases_lab/erin/Bio_project_SRA/pipeline_files/C_Vir_subset


#HISAT2 code
#Indexing a reference genome and no annotation file (allowing for novel transcript discovery)
	#create new directory for the HISAT index called genome, and put the genome inside it
	# copy all reads files into this directory as well to ensure easy access by commands

#Build HISAT index with cvir_edited ( this file has extra spaces in header removed so that genome and annotation don't conflict)
hisat2-build -f $F/cvir_edited.fa cvir_edited

# -f indicates that the reference input files are FASTA files
#Stay in the directory created in the previous step

#Aligning paired end reads
array1=($(ls $F/*_1.fq.clean.trim.filter))

for i in ${array1[@]}; do
	hisat2 --dta -x $F/cvir  -1 ${i} -2 $(echo ${i}|sed s/_1/_2/) -S ${i}.sam
	echo "HISAT2 PE ${i}" $(date)
done
 	#don't need -f because the reads are fastq
	# put -x before the index
	# --dta : Report alignments tailored for transcript assemblers including StringTie.
	 #With this option, HISAT2 requires longer anchor lengths for de novo discovery of splice sites. 
	 #This leads to fewer alignments with short-anchors, which helps transcript assemblers improve significantly in computation and memory usage.

#Aligning single end reads
array2=($(ls $F/*.fastq.clean.trim.filter))

for i in ${array2[@]}; do
        hisat2 --dta -x $F/cvir -U ${i} -S ${i}.sam
        echo "HISAT2 SE ${i}" $(date)
done
	
	#This runs the HISAT2 aligner, which aligns a set of unpaired reads to the genome region using the index generated in the hisat-build step


#SAMTOOLS sort to convert the SAM file into a BAM file to be used with StringTie
#SHOULD NOT PERFORM FILTERING ON HISAT2 OUTPUT
array3=($(ls $F/*.sam))
	for i in ${array3[@]}; do
		samtools sort ${i} > ${i}.bam #Stringtie takes as input only sorted bam files
		echo "${i}_bam"
	done

#Get bam file statistics for percentage aligned with flagstat
# to get more detailed statistics use $ samtools stats ${i}
array4=($(ls $F/*.bam))
	for i in ${array4[@]}; do
		samtools flagstat ${i} > ${i}.bam.stats #get % mapped
	#to extract more detailed summary numbers
		samtools stats {i} | grep ^SN | cut -f 2- > ${i}.bam.fullstat
		echo "STATS DONE" $(date)
	done

echo "FULLY DONE" $(date)
#reference: Transcript-level expression analysis of RNA-seq experiments with HISAT, StringTie, and Ballgown
#http://www.htslib.org/doc/samtools.html