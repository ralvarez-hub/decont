# This script should download the url specified in the first argument ($1), place it in the directory specified in the second argument ($2)
wget -nc -P $2 $1

# and *optionally* uncompress the downloaded file with gunzip if the third argument contains the word "yes".

if [ "$3" == "yes" ]
then
    gunzip -k -f $2/*.gz
fi
