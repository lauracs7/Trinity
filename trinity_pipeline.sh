#! /bin/bash

PARAMS=$1

## Parameters

WD=$(grep working_directory $PARAMS | awk '{print $2}')
echo $WD
MAIN_FOLDER=$(grep main_folder $PARAMS | awk '{print $2}')
echo $MAIN_FOLDER
INS_DIR=$(grep installation_folder $PARAMS | awk '{print $2}') 
echo $INS_DIR
TRINITY=$(grep trinity $PARAMS | awk '{print $2}')
echo $TRINITY
TRANSDECODER=$(grep transdecoder $PARAMS | awk '{print $2}')
echo $TRANSDECODER
NUM_SAMPLES=$(grep num_samples $PARAMS | awk '{print $2}')
echo $NUM_SAMPLES
ACC_SAMPLES1=$(grep acc_sample1 $PARAMS | awk '{ print $2 }')
ACC_SAMPLES2=$(grep acc_sample2 $PARAMS | awk '{ print $2 }')

#Creating working directory
cd $WD 
mkdir $MAIN_FOLDER
cd $MAIN_FOLDER
mkdir samples results log
cd samples
mkdir sample_1 sample_2
cd sample_1
fastq-dump --split-files $ACC_SAMPLES1
fastqc ${ACC_SAMPLES1}_1.fastq
fastqc ${ACC_SAMPLES1}_2.fastq

cd ../sample_2
fastq-dump --split-files $ACC_SAMPLES2
fastqc ${ACC_SAMPLES2}_1.fastq
fastqc ${ACC_SAMPLES2}_2.fastq


cd $WORK_DIR/$MAIN_FOLDER/results

insilico_read_normalization.pl —-seqType fq —-JM 2GB —max_cov 3

$TRINITY/Trinity --seqType fq --max_memory 1G --CPU 4 --left ../samples/sample_1/${ACC_SAMPLES1}_1.fastq,../samples/sample_2/${ACC_SAMPLES2}_1.fastq --right ../samples/sample_1/${ACC_SAMPLES1}_2.fastq,../samples/sample_2/${ACC_SAMPLES2}_2.fastq --trimmomatic

grep “>” Trinity.fasta | wc -l

##Transdecoder
cd $TRANSDECODER
Transdecoder.LongOrfs -t Trinity.fasta

cd $TRINITY
hmmpress Pfam-A.hmm
hmmscan --cpu 8 --domtblout pfam.domtblout Pfam-A.hmm longest_orfs.pep

cd $TRANSDECODER
TransDecoder.Predict -t Trinity.fasta --retain_pfam_hits pfam.dombtblout
