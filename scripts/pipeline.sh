#Download all the files specified in data/urls

wget $(cat data/urls) -P data

# Download the contaminants fasta file, and uncompress it

bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes

# Index the contaminants file

bash scripts/index.sh res/contaminants.fasta res/contaminants_idx/

# Merge the samples into a single file

for sid in $(ls data/*.fastq.gz | cut -d"/" -f2 | cut -d"-" -f1 |uniq)
do
    bash scripts/merge_fastqs.sh data out/merged $sid
done

# Run cutadapt for all merged files

mkdir -p out/trimmed
mkdir -p log/cutadapt
for sid in $(ls out/merged | cut -d"/" -f3 | cut -d"." -f1)
do
   cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed -o out/trimmed/$sid.trimmed.fastq.gz out/merged/$sid.fastq.gz > log/cutadapt/$sid.log
done

#Run STAR for all trimmed files
for fname in out/trimmed/*.fastq.gz
do
    # you will need to obtain the sample ID from the filename
    sid=$(basename $fname .trimmed.fastq.gz)
    mkdir -p out/star/$sid
    STAR --runThreadN 4 --genomeDir res/contaminants_idx --outReadsUnmapped Fastx --readFilesIn "$fname" --readFilesCommand zcat --outFileNamePrefix out/star/$sid/
done 

# Create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci

for sid in $(ls log/cutadapt | cut -d"." -f1)
do
    echo "$sid" >> log/pipeline.log
    cat log/cutadapt/$sid.log | grep "Reads with adapters: " >> log/pipeline.log
    cat log/cutadapt/$sid.log | grep "Total basepairs" >> log/pipeline.log
    cat out/star/$sid/Log.final.out | grep "Uniquely mapped reads %" >> log/pipeline.log
    cat out/star/$sid/Log.final.out | grep "% of reads mapped to multiple loci" >> log/pipeline.log
    cat out/star/$sid/Log.final.out | grep "% of reads mapped to too many loci" >> log/pipeline.log
done
