#!/bin/bash

DEBUG=1

workdir="/var/comics"
template="gen.tmpl"

tmpl="${workdir}/${template}"


if [ -f *.cbz ] && [ -f *.cbr ] ; then
    echo "This script requires ONE cbr or cbz file only to function properly."
    exit 1
fi

cmd="unrar e "
file=$(ls *cbr)
if [ -z "$file" ] ; then
    cmd="unzip"
    file=$(ls *cbz) 
    if [ -z "$file" ] ; then
        echo "This script requires at least one cbr or cbz file to function."
        exit 1
    fi
    n=0
    for i in $file ; do 
        n=$((n + 1))
    done
    if [[ "$n" > 1 ]] ; then
        echo "This script requires ONE cbr or cbz file only to function properly."
        exit 1
    fi
fi
echo Ëxtracting $file...
echo $cmd \"$file\"
$cmd "${file}"

echo my @img_src = \( >> gen$$.pl
jpg_count=$(ls -1 --color=never *jpg | wc -l)
ls -1 --color=never *jpg | sed "s/^/'/" | sed "s/\$/'/" > jpg$$.include
last=$((jpg_count - 1))
sed -i "1,${last}s/$/, /" jpg$$.include
sed -i "${jpg_count},${jpg_count}s/$/); /" jpg$$.include

echo "#!/usr/bin/perl" >> gen.pl
echo >> gen.pl
cat gen$$.pl >> gen.pl
cat jpg$$.include >> gen.pl
cat "$tmpl" >> gen.pl
chmod +x ./gen.pl

echo "Generating HTML files..."
./gen.pl
echo "Cleaning up.."
[[ $DEBUG == 1 ]] || rm ./jpg$$.include
[[ $DEBUG == 1 ]] || rm ./gen$$.pl
[[ $DEBUG == 1 ]] || rm ./gen.pl
