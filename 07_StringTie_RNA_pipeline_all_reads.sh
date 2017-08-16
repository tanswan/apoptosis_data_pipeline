#!/bin/bash
#PBS-l nodes=2
#PBS-l walltime=1000:00:00
#PBS -j oe

set -e
echo "START" $(date)

#8_8_17
#This script takes bam files from HISAT (processed by SAMtools) and performs StringTie assembly and quantification and converts
# data into a format that is readable as count tables for DESeq2 usage


module load StringTie/1.3.3b-foss-2016b
module load gffcompare/0.10.1-foss-2016b

cd /data3/marine_diseases_lab/erin/Bio_project_SRA/pipeline_files
F= /data3/marine_diseases_lab/erin/Bio_project_SRA/pipeline_files

# StringTie to assemble transcripts for each sample with the GFF3 annotation file
array1=($(ls $F/*.bam))

for i in ${array1[@]}; do
	stringtie -G /data3/marine_diseases_lab/erin/Bio_project_SRA/pipeline_files/Crassostrea_gigas.gff -o ${i}.gtf -l $(echo ${i}|sed "s/\..*//") ${i}
	echo "${i}"
done 
	# command structure: $ stringtie <options> -G <reference.gtf or .gff> -o outputname.gtf -l prefix_for_transcripts input_filename.bam
	# -o specifies the output name
	# -G specifies you are aligning with an option GFF or GTF file as well to perform novel transcript discovery 
	# -l Sets <label> as the prefix for the name of the output transcripts. Default: STRG
	# don't use -e here if you want it to assemble any novel transcripts
	
#StringTie Merge, will merge all GFF files and assemble transcripts into a non-redundant set of transcripts, after which re-run StringTie with -e
	#create mergelist.txt in nano, names of all the GTF files created in the last step with each on its own line
	#ls *.gtf > mergelist.txt

	#check to sure one file per line
	#cat mergelist.txt

	#Run StringTie merge, merge transcripts from all samples (across all experiments, not just for a single experiment)

 	stringtie --merge -G /data3/marine_diseases_lab/erin/Bio_project_SRA/pipeline_files/Crassostrea_gigas.gff -o stringtie_merged.gtf mergelist.txt


#gffcompare to compare how transcripts compare to reference annotation

 	gffcompare -r /data3/marine_diseases_lab/erin/Bio_project_SRA/pipeline_files/Crassostrea_gigas.gff -G -o merged stringtie_merged.gtf
	# -o specifies prefix to use for output files
	# -r followed by the annotation file to use as a reference
 	# merged.annotation.gtf tells you how well the predicted transcripts track to the reference annotation file
 	# merged.stats file shows the sensitivity and precision statistics and total number for different features (genes, exons, transcripts)

#Re-estimate transcript abundance after merge step
	for i in ${array1[@]}; do
		stringtie -e -G /data3/marine_diseases_lab/erin/Bio_project_SRA/pipeline_files/stringtie_merged.gtf -o $(echo ${i}|sed "s/\..*//").merge.gtf ${i}
		echo "${i}"
	done 
	# input here is the original set of alignment files
	# here -G refers to the merged GTF files
	# -e creates more accurate abundance estimations with input transcripts, needed when converting to DESeq2 tables

# Protocol to generate count matrices for genes and transcripts for import into DESeq2 using (prepDE.py) to extract this read count information directly from the files generated by StringTie (run with the -e parameter).
	#generates two CSV files containing the count matrices for genes and transcripts, Given a list of GTFs, which were re-estimated upon merging create sample_list.txt
	
#Generate count matrices using prepDE.py, prep_DE.py accepts a .txt file listing sample IDs and GTFs paths 
#create sample_list.txt
array2=($(ls $F/*.merge.gtf))
	
for i in ${array2[@]}; do
	echo "$(echo ${i}|sed "s/\..*//") ${i}" >> sample_list.txt #this almost does what I want it to, but it prints the first path too
done
	
python prepDE.py -i sample_list.txt
			
#Steps continued in R, 08_DESeq_RNA_pipeline_just_pathogen_challenge.R

#Helpful reference website http://ccb.jhu.edu/software/stringtie/index.shtml?t=manual