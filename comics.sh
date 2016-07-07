# this file can be sourced by your bash shell, or sourced as needed when working with CBR files..
# also it is required for the script make_comics.sh
#
# John Newman 6/2016

cbr2html="$HOME/bin/cbr2html.sh"

makeCBRdirs () 
{ 
    for f in *[cC][bB][rRzZ];
    do
        extension=$(echo "$f" | sed 's/.*\.\(...\)$/\1/');
        dir=$(basename "$f" ".${extension}");
        mkdir "$dir";
        mv "$f" "$dir";
    done
}

makeCBR() 
{ 
    pwd=$(pwd);
    for d in *;
    do
        cd "$pwd/$d";
        $cbr2html
    done
}

do_cbrs()
{
    makeCBRdirs
    makeCBR
} 

makeCBRfixpound()
{
    for f in *.jpg ; do
        n=$(echo "$f" | sed 's/#//g')
        mv "$f" "$n"
    done
    sed -i'.rmbak' 's/#//g' *.html
    rm *.rmbak
}

help_comics()
{

cat <<EOF
Functions availble for dealing with CBR/CBZ files, unpacking them and generating HTML:

makeCBRdirs () 
 - create all the directories for each CBR file in the current directory
makeCBR() 
 - iterate through all directories in current directory, and process the CBR in each directory, unpacking and generating HTML
do_cbrs()
 - wrapper around the two above mentioned functions
makeCBRfixpound()
 - web browsers get confused if any of the image names have a '#' sign in them - this will go through the current directory, rename all the jpgs, and correct the HTML
~/bin/make_comics.sh
 - a less fragile version of do_cbrs, also automatically runs makeCBRfixpound

EOF
}

