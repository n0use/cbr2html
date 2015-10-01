#!/usr/local/bin/bash
#
# convert all the CBR/CBZ files in a given directory to HTML
# depends on the shell/perl script cb2html.sh exists in $PATH
# all code by John Newman jnn@synfin.org 09/15

make_html_comics () 
{ 
    _cwd=$(pwd);
    for f in *[Cc][Bb][RrZz] ; 
    do
        dir=$(echo $f | awk -F. '{ print $1 }');
        mkdir "${_cwd}/$dir";
        mv "$f" "${_cwd}/$dir";
        cd "${_cwd}/$dir";
        cbr2html.sh;
        cd "${_cwd}";
    done
}

export PATH=$PATH:~/bin/

if [ -n "$1" ] ; then
    dir="$1"
else
    dir="."
fi

cd "$dir" &> /dev/null || { echo -e "Usage: $0 [dir]\n Fatal error - could not access directory '$dir'\n" ; exit 1; }

echo "$0: operating on directory '$dir' (" $(pwd) ")"
make_html_comics
exit 0
