#Download all the files specified in data/urls
echo '+++++++++++++++++++'
echo 'Downloading samples'
echo '+++++++++++++++++++'
wget -nc $(cat data/urls) -P data

# Download the contaminants fasta file, and uncompress it
echo '+++++++++++++++++++++++++++++'
echo 'Downloading contaminants file'
echo '+++++++++++++++++++++++++++++'
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes

# Index the contaminants file
if [ -d res/contaminants_idx ]
then
    echo '===================='
    echo 'Index already exists'
    echo '===================='
else
    echo '++++++++++++++++++++++++++'
    echo 'Indexing contaminants file'
    echo '++++++++++++++++++++++++++'
    bash scripts/index.sh res/contaminants.fasta res/contaminants_idx/
fi

# Merge the samples into a single file
if [ -d out/merged ]
then
    echo '======================'
    echo 'Samples already merged'
    echo '======================'
else
    echo '+++++++++++++++'
    echo 'Merging samples'
    echo '+++++++++++++++'
    for sid in $(ls data/*.fastq.gz | cut -d"/" -f2 | cut -d"-" -f1 |uniq)
    do
       bash scripts/merge_fastqs.sh data out/merged $sid
    done
fi

# Run cutadapt for all merged files
if [ -d out/trimmed ]
then
    echo '========================'
    echo 'Adaptors already trimmed'
    echo '========================'
else
    echo '++++++++++++++++'
    echo 'Running cutadapt'
    echo '++++++++++++++++'
    mkdir -p out/trimmed
    mkdir -p log/cutadapt
    for sid in $(ls out/merged | cut -d"/" -f3 | cut -d"." -f1)
    do
       cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed -o out/trimmed/$sid.trimmed.fastq.gz out/merged/$sid.fastq.gz > log/cutadapt/$sid.log
    done
fi

#Run STAR for all trimmed files
if [ -d out/star ]
then
   echo '======================='
   echo 'Samples already aligned'
   echo '======================='
else
   echo '+++++++++++++++'
   echo 'Alining samples'
   echo '+++++++++++++++'
   for fname in out/trimmed/*.fastq.gz
   do
      # you will need to obtain the sample ID from the filename
      sid=$(basename $fname .trimmed.fastq.gz)
      mkdir -p out/star/$sid
      STAR --runThreadN 4 --genomeDir res/contaminants_idx --outReadsUnmapped Fastx --readFilesIn "$fname" --readFilesCommand zcat --outFileNamePrefix out/star/$sid/
   done
fi 

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
