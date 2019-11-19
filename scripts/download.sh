# This script should download the url specified in the first argument ($1), place it in the directory specified in the second argument ($2)
wget -P $2 $1
gunzip -k $2/*.gz

# and *optionally* uncompress the downloaded file with gunzip if the third argument contains the word "yes".
#if ["$3" == "yes"]
#then
#    echo "$3"
#   wget -P $2 $1 | gunzip -k basename ls $2
#else
#   wget -P $2 $1
#fi
