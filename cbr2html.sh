#!/bin/bash

function do_help()
{
    cat <<EOF
Usage: $0 [opts]

 There must be a single cbr or cbz file present in the working
 directory for the script to process.  For batch processing of
 multiple files/directories, look at the makeCBRdirs and makeCBR
 commands.

 Supported options are -

 -c|-clean|--clean
      used to clean up garbage template files and perl source,
      left-overs that may be present after a failed or aborted run

 -d|-debug|--debug
      enable debug mode - this leaves the template (tmpl) and the
      auto-generated perl scripts in place, without cleaning them
      up.  It also increases verbosity of reporting.

 -r|-removecbr|--removecbr
      normally $0 does NOT remove the source cbr/cbz file that is
      being processed... With this option, it WILL remove that file

 -h|-help|--help
      the usage help you are reading now

EOF
}


function check_args()
{
    for arg in $* ; do
        if [[ $arg =~ ^-d|^-debug|^--debug ]] ; then
            DEBUG=1
        elif [[ $arg =~ ^-c|^-clean|^--clean ]] ; then
            CLEAN=1
        elif [[ $arg =~ ^-r|^--remove|^-remove ]] ; then
            REMOVE_CBR=1
        elif [[ $arg =~ ^-h|^-help|^--help ]] ; then
            do_help
            exit 0
        fi
    done
}            


DEBUG=0
CLEAN=0
REMOVE_CBR=0

check_args $*

workdir="${HOME}/var/cbr2html"
template="gen.tmpl"
ls=$(which ls)

tmpl="${workdir}/${template}"


if [ $CLEAN = "1" ] ; then
    echo "Cleaning up previous run garbage.."
    rm -f *jpg gen* *include* *html
    exit 0
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
gsed -i "s/'/\\\'/g" jpg$$.include
gsed -i "s/^/'/" jpg$$.include 
gsed -i "s/\$/'/" jpg$$.include
gsed -i "1,${last}s/$/, /" jpg$$.include
gsed -i "${jpg_count},${jpg_count}s/$/); /" jpg$$.include

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
if [[ $REMOVE_CBR == 1 ]] ; then 
    echo "Removing source file \"$file\".."
    rm "$file"
fi
