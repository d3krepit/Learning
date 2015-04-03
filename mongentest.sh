#!/bin/bash

#These are defined for colors if an error occurs
Escape="\033";
RedF="${Escape}[31m";
Reset="${Escape}[0m";

# Usage Help
usage="Usage: mongen.sh foo.csv\n
        Sample foo.csv config:\n\n
        S24-MONPL01,67.216.191.99,linux,vm,u1dcd,avamar\n
        [Hostname],[Datacenter],[Service1],[Service2],[ServiceN]\n\n
        DATACENTER Options: U0DCD, U0DCB, U0DCF, U1DCD, U1DCB, U1DCE, SOI, CFSDCB, CFSDCD\n
        Contact EnterpriseMonitoringTeam@Secure-24.com with any questions.\n"

# Check for correct amount of arguments
if [ ! $# -eq 1 ]; then
        echo ""
        echo -e "${RedF}Incorrect arguments specified. Please supply the csv file path/name.${Reset}"
        echo ""
        echo -e $usage
        exit 1;
fi

if [ $1 = "-h" ]; then
  echo -e $usage
  exit 0
fi

# Set up variables for use in file creation.
SCRIPT=`readlink -f $0`
SCRIPTDIR=`dirname $SCRIPT`
TEMPLATEDIR="~/monitoring_scripts/templates"
CONFIGFILE=".mongen"


 if [ -r $HOME/$CONFIGFILE ] ; then
     REPOBASE=`grep repobase $HOME/$CONFIGFILE|awk -F"=" '{print $2}'`
  else
    read -p "Please enter the base for your GIT repositories (do not include the host name): " REPOBASE
    echo "repobase=$REPOBASE" >> $HOME/$CONFIGFILE
 fi


check_repo()
{
        MONSERVER=$1
        #echo -e "\t[ Checking repo $REPOBASE/$MONSERVER ]"
 if [ ! -d $REPOBASE/$MONSERVER ]; then
        echo -e "\t\t${RedF}Repo is not checked out at $REPOBASE/$MONSERVER${Reset}"
        return 1
 fi
return 0

}

add_configs()
{
    echo -ne "\t[ Adding configuration ("
 
	for c in ${CHECKS[@]}
		do
			echo $c
			#cat $TEMPLATEDIR/$c.template | sed "s/SYSTEMHOSTNAME/$SYSTEMHOSTNAME/g" | sed "s/CLIENTABBREVIATION/$CLIENT/g" >> $REPOBASE/$MONSERVER/objects/clients/$CONFIGDIR/$SYSTEMHOSTNAME.cfg
		done
}

check_cust()
{
        #echo -e "\t[ Checking customer... ]"
MONSERVER=$1
CLIENTUP=`echo $SYSTEMHOSTNAME | cut -d- -f1 | tr [:lower:] [:upper:]`
CLIENT=`echo $CLIENTUP | tr [:upper:] [:lower:]`
if [[ "$CLIENTUP" == "TDAF" ]]; then
        CLIENTUP="CFS"
        CLIENT="cfs"
fi
ls -d $REPOBASE/$MONSERVER/objects/clients/* 2> /dev/null | grep $CLIENTUP >/dev/null 2>&1
CLIENTDIR=$?

   # Determine if the client in the CSV file exists, and where. If not, create new directory and warn.
        if [ "$CLIENTDIR" -eq 0 ]; then
          CONFIGDIR="$CLIENTUP"
                                                                          else
          if [[ "$SYSTEMHOSTNAME" == *-* ]]; then
            CONFIGDIR="$CLIENTUP"
            echo -e "\t\t${RedF}*WARNING* Could not find $CLIENTUP in $REPOBASE. Creating $CLIENTUP.${Reset}"
            mkdir $REPOBASE/$MONSERVER/objects/clients/$CLIENTUP
          else
            CONFIGDIR="unsorted_hosts"
            echo -e "\t\t${RedF}*WARNING* Could not determine client code. Adding config to unsorted_hosts.${Reset}"
          fi
        fi

}

while read X; do
        
		SYSTEMHOSTNAME=`echo $X | cut -d, -f1 | tr [:lower:] [:upper:]`
        SYSTEMALIAS=$SYSTEMHOSTNAME
        DC=`echo $X | cut -d, -f2 | tr [:upper:] [:lower:]`
        NUMCOMS=echo $X | tr -d -c ',' | wc -c
        ONE='1'
        NUMCHKS=$(($NUMCOMS + $ONE))
        declare -a CHECKS
		CHECKS=0
                for ((i=3;i<=$NUMCHKS;i++))
                        do
                            CHECKS+=` echo $X | cut -d, -f${i} | tr [:upper:] [:lower:] `
                        done

        POLLNODE=""
        PRESNODE=""
        echo "[Reading line for $SYSTEMHOSTNAME...]"

        # DC Verification and Poller/Presentation assignment
        if [ -n $DC ]; then
          case $DC in
                u0dcb)  PRESNODE="s24-monpl02";;
                u0dcd)  PRESNODE="s24-monpl32"
                        POLLNODE="s24-monpl31";;
                u0dcf)  PRESNODE="s24-monpl32"
                        POLLNODE="s24-nagpl01";;
                u1dcd)  PRESNODE="s24-monpl32"
                        POLLNODE="msp-nagpl30";;
                u1dcb)  PRESNODE="s24-monpl32"
                        POLLNODE="msp-nagpl10";;
                u1dce)  PRESNODE="s24-monpl32"
                        POLLNODE="msp-nagpl40";;
                soi)    PRESNODE="s24-monpl32"
                        POLLNODE="soi-nagpl01";;
                cfsdcb) PRESNODE="s24-monpl32"
                        POLLNODE="cfs-nagpl02";;
                cfsdcd) PRESNODE="s24-monpl32"
                        POLLNODE="cfs-nagpl01";;
                 *)     echo -e "${RedF}Invalid DC \"$DC\" specified, exiting${Reset}"
                       exit 3;;
         esac
        else
          echo -e "${RedF}No DC entered, this is required, exiting...${Reset}"
          exit 2
       fi
  
## STEPS to be done
## check if the repo exists, if not clone it, if so, pull it
## if needed, create the poller configs, keep file list for git add command
## add/commit/push poller changes
## create presentation configs, keep file list for git add command
## add/commit/push presentation changes

        #echo "[ Checking poller node... ]"
        if [ ! "$POLLNODE" == "" ]; then
         #echo -e "\tPoller node variable, "$POLLNODE", found!"
         check_repo $POLLNODE
         if [ $? -eq 0 ]; then
          check_cust $POLLNODE
           if [ $? -eq 0 ]; then
            add_configs $POLLNODE
           fi
         fi
        fi


        #echo "[ Checking presentation node... ]"
        if [ ! "$PRESNODE" == "" ]; then
         #echo -e "\tPresentation node variable, "$PRESNODE", found!"
                check_repo $PRESNODE
                if [ $? -eq 0 ]; then
                   check_cust $PRESNODE
            
                        if [ $? -eq 0 ]; then
                            add_configs
                        fi
                fi
        #else
        #       echo -e "\tNo presentation node..."
        fi

done < $1