#!/usr/bin/env bash

experimenter=$2
timestamp=$(date --utc)
system=$(uname -snrmo)
memory=$(free -h)
totalmemory=$(echo $memory | perl -n -e'/.*Mem:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $1')
usedmemory=$(echo $memory | perl -n -e'/.*Mem:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $2')
freememory=$(echo $memory | perl -n -e'/.*Mem:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $3')
sharedmemory=$(echo $memory | perl -n -e'/.*Mem:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $4')
buffcachememory=$(echo $memory | perl -n -e'/.*Mem:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $5')
availablememory=$(echo $memory | perl -n -e'/.*Mem:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $6')
totalswap=$(echo $memory | perl -n -e'/.*Swap:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $1')
usedswap=$(echo $memory | perl -n -e'/.*Swap:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $2')
freeswap=$(echo $memory | perl -n -e'/.*Swap:\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)\s([0-9\.A-Z]+)/ && print $3')
command=$3
usertime=$(perl -n -e'/user\s([0-9\.ms]+)/ && print $1' < $1)
systemtime=$(perl -n -e'/sys\s([0-9\.ms]+)/ && print $1' < $1)
percentcpu=
elapsedtime=$(perl -n -e'/real\s([0-9\.ms]+)/ && print $1' < $1)
maxresidentsetsize=
avgresidentsetsize=
majorpagefaults=
minorpagefaults=
voluntarycontextswitches=
involuntarycontextswitches=
swaps=
filesysteminputs=
filesystemoutputs=
socketmessagessent=
socketmessagesreceived=
signalsdelivered=
pagesize=
echo "$experimenter,$timestamp,$system,$totalmemory,$usedmemory,$freememory,$sharedmemory,$buffcachememory,$availablememory,$totalswap,$usedswap,$freeswap,$command,$usertime,$systemtime,$percentcpu,$elapsedtime,$maxresidentsetsize,$avgresidentsetsize,$majorpagefaults,$minorpagefaults,$voluntarycontextswitches,$involuntarycontextswitches,$swaps,$filesysteminputs,$filesystemoutputs,$socketmessagessent,$socketmessagesreceived,$signalsdelivered,$pagesize" > .csvLine
cat .csvLine
rm .csvLine