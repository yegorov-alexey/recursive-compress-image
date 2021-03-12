#!/bin/bash

if [ -z "$1" ]; then
    echo -e "\nPlease call '$0 <directory>' to run this command!\n"
    exit 1
fi

let i=0
function countRecursively() {
for file in "$1"/*
do
    if [ ! -d "${file}" ] ; then
      # echo "${file} is a file"
		if [ ${file: -5} == ".jpeg" ]; then
		  let i++
		fi
		if [ ${file: -4} == ".jpg" ]; then
		 let i++
		fi
		if [ ${file: -4} == ".png" ]; then
		  let i++
		fi
    else
        #echo -ne "entering recursion with: ${file}\r"
        countRecursively "${file}"
		cd ..
    fi
done
}
progress-bar() {
  local elapsed=${1}
  local duration=${2}

    already_done() { for ((done=0; done<$elapsed; done++)); do printf "▇"; done }
    remaining() { for ((remain=$elapsed; remain<$duration; remain++)); do printf " "; done }
    percentage() { printf "| %s%%" $(( (($elapsed)*100)/($duration)*100/100 )); }
    clean_line() { printf "\r"; }

      already_done; remaining; percentage
      clean_line
  clean_line
}

let ii=0
function compressRecursively() {
for file in "$1"/*
do
    if [ ! -d "${file}" ] ; then
      # echo "${file} is a file"
		if [ ${file: -5} == ".jpeg" ]; then
		  progress-bar "$(($ii*100/$i))" 100
		  convert "${file}" -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace sRGB "${file}"
		  let ii++
		fi
		if [ ${file: -4} == ".jpg" ]; then
      progress-bar "$(($ii*100/$i))" 100
		  convert "${file}" -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace sRGB "${file}"
		  ((ii=ii+1))
		  let ii++
		fi
		if [ ${file: -4} == ".png" ]; then
		  progress-bar "$(($ii*100/$i))" 100
		  pngquant --quality=85 -f --ext .png "${file}"
		  let ii++
		fi
    else
        #echo -ne "entering recursion with: ${file}\r"
        compressRecursively "${file}"
		cd ..
    fi
done
}

function main() {
    countRecursively "$1"
    compressRecursively "$1"
    echo ""
    echo "Finished: found ${i} files"
}

main "$1"

