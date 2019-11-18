#Download all the files specified in data/urls

for url in $(cat /home/user16/adv-shell-final/decont/data/urls)
do
    bash /home/user16/adv-shell-final/decont/scripts/download.sh $url "/home/user16/adv-shell-final/decont/data"
done

# Download the contaminants fasta file, and uncompress it
#bash scripts/download.sh <contaminants_url> res yes #TODO

# Index the contaminants file
#bash scripts/index.sh res/contaminants.fasta res/contaminants_idx

# Merge the samples into a single file
#for sid in $(<list_of_sample_ids) #TODO
#do
#    bash scripts/merge_fastqs.sh data out/merged $sid
#done

# TODO: run cutadapt for all merged files
# cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed -o <trimmed_file> <input_file> > <log_file>

#TODO: run STAR for all trimmed files
for fname in out/trimmed/*.fastq.gz
do
    # you will need to obtain the sample ID from the filename
    sid=#TODO
    # mkdir -p out/star/$sid
    # STAR --runThreadN 4 --genomeDir res/contaminants_idx --outReadsUnmapped Fastx --readFilesIn <input_file> --readFilesCommand zcat --outFileNamePrefix <output_directory>
done 

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
