#!/bin/bash

d=$(date +"%b-%d-%y %H:%M")
t=$1
dir=targets/"${t}-${d}"
if [ $t >& /dev/null -z ];
         then  echo -e  "\e[1;31m Please Specify a domain \e[0"
else
     echo -e "\e[1;32m Recon started on: \e[0" $d
     echo -e "\e[1;32m Buiding Target Directory \e[0"
     sleep 1
     mkdir "${dir}"
     echo -e "\e[1;32m Hunting Subdomains! \e[0"
     sleep 2
    # python massdns/scripts/subbrute.py massdns/lists/names.txt $t | massdns/bin/massdns -r massdns/lists/resolvers.txt -t A -o S -w "${dir}"/subbrute-domains.txt
    # python3 massdns/scripts/ct.py $t | massdns/bin/massdns -r massdns/lists/resolvers.txt -t A -o S -w "${dir}"/cert-domains.txt
     python3 virustotal_subdomain_enum.py $t 40 > "${dir}"/virustotal-domains.txt
     python3 san_subdomain_enum.py $t > "${dir}"/sans-domains.txt
     python3 Turbolist3r/turbolist3r.py -d $t -t 15 -o "${dir}"/turbolister-domains.txt
     python3 github-subdomains.py -d $t > "${dir}"/github-subdomains.txt
     subfinder -d $t > "${dir}"/subfinder-domains.txt
     #sublist3r -d $t -t 5 -o "${dir}"/sublister-domains.txt
     findomain-linux -t $t  -u "${dir}"/findomain-domains.txt
     anubis -t $t -o "${dir}"/anubis-domains.txt
     curl -s https://dns.bufferover.run/dns?q=.$t | sed -s 's/,/\n/g' | sed -s 's/"/\n/g' | egrep '(.+)\.'${t}'' | tee "${dir}"/bufferoverun-domains.txt
     echo -e "\e[1;31m Subdomains enumeration complete! \e[0"
     echo -e "\e[1;31m Extracting subdomains and ip address! \e[0"
     sleep 2
     #Extract Ips
    # egrep -h  -o '[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}' "${dir}"/subbrute-domains.txt "${dir}"/cert-domains.txt | sort -u  > "${dir}"/ips.txt
     #Extract domains
     #egrep -h -i -o '(.+)\.%s' "${dir}"/subbrute-domains.txt "${dir}"/cert-domains.txt "${dir}"/findomain-domains.txt "${dir}/anubis-domains.txt" | grep -v 'CNAME' > "${dir}"/subdomains.txt
     cat "${dir}"/bufferoverun-domains.txt >> "${dir}"/subdomains.txt
     cat "${dir}"/turbolister-domains.txt  >> "${dir}"/subdomains.txt
     cat "${dir}"/github-subdomains.txt >> "${dir}"/subdomains.txt
     egrep '(.+)\.${t}' "${dir}"/virustotal-domains.txt >> "${dir}/subdomains.txt"
     egrep '(.+)\.${t}' "${dir}"/sans-domains.txt >> "${dir}/subdomains.txt"
     egrep '(.+)\.${t}' "${dir}"/subfinder-domains.txt >> "${dir}/subdomains.txt"
     sed -i 's/<BR>/\n/g' "${dir}"/subdomains.txt
     sort -u "${dir}"/subdomains.txt | uniq >> "${dir}"/domains.txt
     echo 'Extracting More assest if there'
     ./ex.sh $t "${dir}"/domains.txt
     sleep 3
     echo -e "                        \e[1;31m Probing A and CNAMEs for the domains \e[0"
     sleep 3
     cat "${dir}"/domains.txt | dnsprobe -r A -o "${dir}"/dnsprobe-A.txt
     cat "${dir}"/domains.txt | dnsprobe -r CNAME -o "${dir}"/dnsprobe-CNAME.txt

     echo -e "                        \e[1;31m Recon Done Boss! \e[0"
fi
