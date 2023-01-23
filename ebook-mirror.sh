#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin

DDIR="/srv/nfs/data/backup/eBooks/Allitebooks"
mkdir -p "$DDIR"

# 1000 for intial full sync / 10 for daily update via cron
SEQ=5

for i in $(seq 1 $SEQ)
do
   echo "get page: http://www.allitebooks.com/page/$i/"
   wget -O - -q http://www.allitebooks.com/page/$i/ | grep 'entry-title' | sed 's/.*http:/http:/;s/\".*//g;/entry-title/d' |  while read title
   do
      echo "      extract ebook from title: $title"
      wget -O - -q $title | egrep '\.pdf"|\.zip"|\.rar"|\.epub"|\.mobi"|\.tgz"|\.tar.gz"|\.gz"|\.lza"' | sed 's/.*http:/http:/;s/\".*//g' | while read pdf
      do
         file=$(echo $pdf | sed 's|.*/||g')
         test -f "$DDIR/$file"
         if [ $? -ne 0 ]
         then
            cd "$DDIR"
            echo "            downloading $file"
            wget -q "$pdf"
         else
            echo "            skipping, $file is present"
         fi
      done
   done
done

