#!/usr/local/bin/bash

source $HOME/sh/comics

_cwd=$(pwd)

comics=$(ls *[cC][bB][rRzZ]  2> /dev/null)  ; 
if [ -z "$comics" ]  ; then
    echo "No CBR/CBZ files foumd... exiting."
    exit 0
fi

echo "Making dirs and HTML for [ $comics ] ...." ; 

makeCBRdirs
makeCBR

cd "$_cwd"
for d in * ; do
    if [ -d "$_cwd/$d" ] ; then
        cd "$_cwd/$d" 
        makeCBRfixpound
    fi
done
