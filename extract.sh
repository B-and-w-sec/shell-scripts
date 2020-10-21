#!/bin/bash
while read url; do echo -e "\n\n -----URL: " $url "------" ;  curl -s $url  |   ruby ~/relative-url-extractor/extract.rb --url  ; done < "$1"
