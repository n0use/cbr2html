#!/bin/bash
#
# convert a single CBR/CBZ file in a given directory to HTML, generate a
# perl script which generates an HTML file for each jpg/image extracted from
# the CBR/CBZ archive file, and also generates an index.html
#
# all code by John Newman jnn@synfin.org 09/15

DEBUG=0

workdir="${HOME}/var/cbr2html"
template="gen.tmpl"

# we prefer gnu-sed - required on *BSD / OSX platforms, regular sed is fine on Linux (cause its already GNU sed..)
sed=$(which gsed)
[ -z "$sed" ] || [ ! -x "$sed" ] && sed="$(which sed)"

ls=$(which ls)

tmpl="${workdir}/${template}"


if [ "$1" = "clean" ] ; then
    echo "Cleaning up previous run garbage.."
    rm -f *jpg gen* *include* *html
    exit 0
fi

if [ "$1" = "debug" ] ; then
    DEBUG=1
fi

if [ -f *.cbz ] && [ -f *.cbr ] ; then
    echo "This script requires ONE cbr or cbz file only to function properly."
    exit 1
fi

cmd="unrar e "
file="$($ls *[Cc][Bb][Rr] 2> /dev/null)"
if [ -z "$file" ] ; then
    cmd="unzip"
    file="$($ls *[Cc][Bb][Zz] 2> /dev/null)"
    if [ -z "$file" ] ; then
        echo "This script requires at least one cbr or cbz file to function."
        exit 1
    fi
    n=0
    for i in "$file" ; do 
        n=$((n + 1))
    done
    if [[ "$n" > 1 ]] ; then
        echo "This script requires ONE cbr or cbz file only to function properly."
        exit 1
    fi
fi
echo Extracting $file...
echo $cmd \"$file\"
$cmd "${file}"
mv */*[jJ][pP][gG] ./ 2> /dev/null
rmdir * 2> /dev/null

echo my @img_src = \( >> gen$$.pl
jpg_count=$($ls -1  *.[jJ][pP][gG] | wc -l)
last=$((jpg_count - 1))
$ls -1  *[jJ][pP][gG]  > jpg$$.include
$sed -i "s/'/\\\'/g" jpg$$.include
$sed -i "s/^/'/" jpg$$.include 
$sed -i "s/\$/'/" jpg$$.include
$sed -i "1,${last}s/$/, /" jpg$$.include
$sed -i "${jpg_count},${jpg_count}s/$/); /" jpg$$.include

echo "#!/usr/local/bin/perl" >> gen.pl
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
