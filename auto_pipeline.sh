#!/bin/sh
if [ $# -lt 4 ]; 
then
	echo "\n";
	echo "Option: sh $0 <nanopore_fastq_prefix> <hla_type_config> <nano2ngs_parametre> <script_path>";
	echo "\n";
	echo "Parametre Info:";
	echo "		<nanopore_fastq_prefix>	Prefix of raw nanopore sequencing fastq file, format: prefix.fastq";
	echo "		<hla_type_config>	Detected HLA type file, required absolute path";
	echo "		<nano2ngs_parametre>	Nano2ngs used parametre";
	echo "		<script_path>		Script absolute path";
	echo "\n"
	echo "Example: sh $0 Sample Absolute-Path/HLA-Type.config \"-read_len 100 -time 10\" Absolute-Path/NanoHLA"
	echo "Note: Users should put the shell scripts and raw_data folder in the same directory. Otherwise, please modify the path where the fastq file stored in the shell script."
	echo "\n";
        echo "====================================================";
        echo "Edit by Jidong Lang; E-mail: langjidong@hotmail.com;";
        echo "====================================================";	
	exit
fi

#Data Preprocessing#
echo "Preprocessing Start----`date`"
mkdir clean_data
porechop -t 4 -i ./raw_data/$1.fastq -o ./clean_data/$1.clean.fq
echo "Preprocessing Finished----`date`"

#Coverage Analysis#
echo "Coverage Analysis Start----`date`"
mkdir Coverage
minimap2 -a -x map-ont $4/database/hla.clean.fasta ./clean_data/$1.clean.fq -t 4 > ./Coverage/$1.sam
$4/bin/soap.coverage -cvg -p 4 -sam -i ./Coverage/$1.sam -refsingle $4/database/hla.clean.fasta -o ./Coverage/$1.coverage.txt
rm -rf ./Coverage/$1.sam
perl $4/bin/Coverage_Filter.pl ./Coverage/$1.coverage.txt ./Coverage/$1.filter.txt
less $2|while read b;do less ./Coverage/$1.filter.txt|grep "_${b}_"|awk '{printf($1"\t"$2"\t""%.2f\n",$3)}'|sort -rnk3 > ./Coverage/HLA-${b}.covfilter.txt;done
echo "Coverage Analysis Finished----`date`"

#Nano2NGS#
echo "Nano2NGS Start----`date`"
mkdir nano2ngs
cd ./nano2ngs
perl $4/bin/nano2ngs.pl -fq ../clean_data/$1.clean.fq $3
ls *.fq > tmp
less tmp|perl -e 'while(<>) {chomp; $_=~s/.fq$//g; print "$_\n";}' > tmp-list
rm tmp
less tmp-list|while read a;do mkdir ${a};done
less tmp-list|while read a;do mv ${a}.fq ${a};done
echo "Nano2NGS Finished----`date`"

#NGS Analyysis Pipeline#
echo "NGS Analysis Pipeline Start----`date`"
less tmp-list|while read a;do echo "/mnt/nas/bioinfo/langjidong/PERL/software/novocraft/novoalign -d /mnt/nas/bioinfo/langjidong/PERL/software/novocraft/reference/hla.ref.nix -f ./${a}/${a}.fq -o SAM -r all -l 80 -e 100 | samtools view -bS -h -F 4 - > ./${a}/${a}.bam" >> analysis.${a}.sh;done
less tmp-list|while read a;do less $2|while read b;do echo -e "samtools sort -o ./${a}/${a}.sort.bam ./${a}/${a}.bam\nsamtools view -b -L /mnt/nas/bioinfo/langjidong/PERL/software/Athlates/db/bed/hla.${b}.bed ./${a}/${a}.sort.bam > ./${a}/${a}.${b}.bam\nsamtools view -h -o ./${a}/${a}.${b}.sam ./${a}/${a}.${b}.bam\nsort -k 1,1 -k 3,3 ./${a}/${a}.${b}.sam > ./${a}/${a}.${b}.sort.sam\nless -S ./${a}/${a}.${b}.sort.sam|grep \"^@\" > ./${a}/title1\nless -S ./${a}/${a}.${b}.sort.sam|grep -v \"^@\" > ./${a}/${a}.${b}.sort.sam.tmp\ncat ./${a}/title1 ./${a}/${a}.${b}.sort.sam.tmp > ./${a}/${a}.${b}.sort.sam\nsamtools view -bS ./${a}/${a}.${b}.sort.sam -o ./${a}/${a}.${b}.sort.bam" >> analysis.${a}.sh;done;done
less tmp-list|while read a;do less $2|while read b;do echo -e "samtools sort -o ./${a}/${a}.sort.bam ./${a}/${a}.bam\nsamtools view -b -L /mnt/nas/bioinfo/langjidong/PERL/software/Athlates/db/bed/hla.non-${b}.bed ./${a}/${a}.sort.bam > ./${a}/${a}.non-${b}.bam\nsamtools view -h -o ./${a}/${a}.non-${b}.sam ./${a}/${a}.non-${b}.bam\nsort -k 1,1 -k 3,3 ./${a}/${a}.non-${b}.sam > ./${a}/${a}.non-${b}.sort.sam\nless -S ./${a}/${a}.non-${b}.sort.sam|grep \"^@\" > ./${a}/title2\nless -S ./${a}/${a}.non-${b}.sort.sam|grep -v \"^@\" > ./${a}/${a}.non-${b}.sort.sam.tmp\ncat ./${a}/title2 ./${a}/${a}.non-${b}.sort.sam.tmp > ./${a}/${a}.non-${b}.sort.sam\nsamtools view -bS ./${a}/${a}.non-${b}.sort.sam -o ./${a}/${a}.non-${b}.sort.bam" >> analysis.${a}.sh;done;done
less tmp-list|while read a;do less $2|while read b;do echo -e "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/mnt/nas/bioinfo/langjidong/PERL/software/SoftSV_1.4.2/bamtools-2.4.1/lib\n/mnt/nas/bioinfo/langjidong/PERL/software/Athlates/bin/typing -bam ./${a}/${a}.${b}.sort.bam -exlbam ./${a}/${a}.non-${b}.sort.bam -o ./${a}/${a}.hla-${b} -msa /mnt/nas/bioinfo/langjidong/PERL/software/Athlates/db/msa/${b}_nuc.txt" >> analysis.${a}.sh;done;done
less tmp-list|while read a;do less analysis.${a}.sh|perl -e 'while(<>) {chomp; $_=~s/^-e //g; print "$_\n";}' > analysis.${a}.sh1;done    #Bug####
less tmp-list|while read a;do mv analysis.${a}.sh1 analysis.${a}.sh;done
ls analysis.*.sh|while read a;do sh ${a} > ${a}.log 2>&1;done    ####Maybe run parallel####
less tmp-list|while read a;do less $2|while read b;do less ./${a}/${a}.hla-${b}.raw.fa|awk '{print $1}'|perl -e 'while(<>) {chomp; if(/^>/) {$n+=1; print "$_\_$n\n"; $seq=<>; print "$seq";}}' > ${a}/${a}.hla-${b}.fa;done;done
less tmp-list|while read a;do rm -rf ${a}/*.bam* ${a}/*.sam* ${a}/*.txt ${a}/*.pair.fa ${a}/*.unpair.fa ${a}/*.raw.fa ${a}/*.contig.fa ${a}/title*;done
less tmp-list|while read a;do less $2|while read b;do blastn -task blastn -query ./${a}/${a}.hla-${b}.fa -db $4/database/hla.clean.fasta -outfmt 6 -num_threads 4 -out ./${a}/${a}.hla-${b}.blast.result -evalue 1e-10 -dust no;done;done
less tmp-list|while read a;do less $2|while read b;do perl $4/bin/length.pl ./${a}/${a}.hla-${b}.fa ./${a}/${a}.hla-${b}.len;done;done
less tmp-list|while read a;do less $2|while read b;do perl $4/bin/filter-blastresult.pl ./${a}/${a}.hla-${b}.blast.result ./${a}/${a}.hla-${b}.len ./${a}/${a}.hla-${b}.tmp;done;done
less tmp-list|while read a;do less $2|while read b;do perl $4/bin/max_result.pl ./${a}/${a}.hla-${b}.tmp ./${a}/${a}.hla-${b}.result1;done;done
cd ../
echo "NGS Analysis Pipeline Finished----`date`"

#Result Prediction#
echo "Result Prediction Start----`date`"
mkdir Result
less $2|while read b;do less ./nano2ngs/tmp-list|while read a;do cat ./nano2ngs/${a}/${a}.hla-${b}.result1;done > ./Result/all.hla-${b}.result;done
less $2|while read b;do perl $4/bin/combine_result.pl ./Result/all.hla-${b}.result ./Coverage/$1.coverage.txt ./Result/HLA-${b}.info;done
less $2|while read b;do less ./Result/HLA-${b}.info|awk '{if($4>=90 && $5>=100) print $0}' > ./Result/HLA-${b}.filter.txt;done
echo "Result Prediction Finished----`date`"

#QC Analysis#
echo "Quality Control Analysis Start----`date`"
mkdir QC
NanoPlot -t 4 --fastq ./clean_data/$1.clean.fq --plots hex dot -o ./QC -p $1
perl $4/bin/static_data.pl ./clean_data/$1.clean.fq ./QC/$1.stat
echo "Quality Control Analysis Finished----`date`"

echo "Congratulations! All tasks have finished!----`date`"
