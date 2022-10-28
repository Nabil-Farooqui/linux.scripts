#!/bin/bash
###############################################################################################################
# DESC: Tool to search and view ansible documentation
# WHO: chris
###############################################################################################################
# Copyright (c) Chris Ruettimann <chris@bitbull.ch>

# This software is licensed to you under the GNU General Public License.
# There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/gpl.txt

###############################################################################################################

SCRIPT="$(basename $0)"
ARG="$*"

do-search(){
   FILES="$(ansible-doc -l | grep -i $ARG | tr ' ' '°' )"
   COUNT=$(echo "$FILES" | wc -l)
   if [ $COUNT -eq 0 ] ; then
      echo nothing found ...
      exit 0
   elif [ "$COUNT" == "1" ] ;  then
      SELECT=1
      view-file
      exit 0
   fi
   SEARCHED=1
}

select-file(){
   clear
   echo
   echo "WHICH DOC DO YOU WANT TO SEE ?"
   echo "------------------------------"
   echo "Search: $ARG"
   ( echo
   for NR in $(seq 1 $COUNT) ; do
      echo -n "   "
      [ $COUNT -ge 10 ] && [ $NR -le 9 ] && echo -n ' '
      echo -n "$NR) " 
      FILE="$(echo $FILES | cut -d\  -f$NR)"
      echo "$FILE" | tr '°' ' '
      NR=$(( $NR + 1 ))
   done
   echo "   q) QUIT" ) | sed 's/^/   /'
   echo
   echo -n "Please select: "
   read SELECT
   if [ "$SELECT" == "q" ] ; then
      exit 0
   fi
}

view-file() 
{
   VIEW=true
   echo "$SELECT" | grep -q '[0123456789]'
   if [ $? -eq 0 ] ; then
      for NR in $(seq 1 $COUNT) ; do
         if [ "$SELECT" == "$NR" ] ; then
            # $EDIT +"set ic|/$ARG" $(echo $FILES | cut -d' '  -f $SELECT)
            ansible-doc $(echo $FILES | cut -d' '  -f $SELECT | tr '°' ' ' | awk '{print $1}')
         fi
      done
   fi
}

###############################################################################

### SEARCH NORMAL
while true
do
   if [ "x" == "x$SEARCHED" ] ;  then
      do-search "$ARG" 
   fi
   select-file "$FILES" 
   view-file "$FILE"
done

