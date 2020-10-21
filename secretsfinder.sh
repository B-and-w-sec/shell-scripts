#!/bin/bash
while read url; do python3 ~/SecretFinder/SecretFinder.py -i $url -o cli ; done < "$1"
