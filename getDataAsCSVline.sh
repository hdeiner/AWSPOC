#!/usr/bin/env bash

experimenter=$2
timestamp=$(date --utc)
system=$(uname -a)
command=$3
usertime=$(perl -n -e'/User time \(seconds\)\:\s([0-9\.\:]+)/ && print $1' < $1)
systemtime=$(perl -n -e'/System time \(seconds\)\:\s([0-9\.\:]+)/ && print $1' < $1)
percentcpu=$(perl -n -e'/Percent of CPU this job got\:\s([0-9]+)/ && print $1' < $1)
elapsedtime=$(perl -n -e'/Elapsed \(wall clock\) time \(h\:mm\:ss or m\:ss\)\:\s([0-9\.\:]+)/ && print $1' < $1)
maxresidentsetsize=$(perl -n -e'/Maximum resident set size \(kbytes\)\:\s([0-9]+)/ && print $1' < $1)
avgresidentsetsize=$(perl -n -e'/Average resident set size \(kbytes\)\:\s([0-9]+)/ && print $1' < $1)
majorpagefaults=$(perl -n -e'/Major \(requiring I\/O\) page faults\:\s([0-9]+)/ && print $1' < $1)
minorpagefaults=$(perl -n -e'/Minor \(reclaiming a frame\) page faults\:\s([0-9]+)/ && print $1' < $1)
voluntarycontextswitches=$(perl -n -e'/Voluntary context switches\:\s([0-9]+)/ && print $1' < $1)
involuntarycontextswitches=$(perl -n -e'/Involuntary context switches\:\s([0-9]+)/ && print $1' < $1)
swaps=$(perl -n -e'/Swaps\:\s([0-9]+)/ && print $1' < $1)
filesysteminputs=$(perl -n -e'/File system inputs\:\s([0-9]+)/ && print $1' < $1)
filesystemoutputs=$(perl -n -e'/File system outputs\:\s([0-9]+)/ && print $1' < $1)
socketmessagessent=$(perl -n -e'/Socket messages sent\:\s([0-9]+)/ && print $1' < $1)
socketmessagesreceived=$(perl -n -e'/Socket messages received\:\s([0-9]+)/ && print $1' < $1)
signalsdelivered=$(perl -n -e'/Signals delivered\:\s([0-9]+)/ && print $1' < $1)
pagesize=$(perl -n -e'/Page size \(bytes\)\:\s([0-9]+)/ && print $1' < $1)
echo "$experimenter,$timestamp,$system,$command,$usertime,$systemtime,$percentcpu,$elapsedtime,$maxresidentsetsize,$avgresidentsetsize,$majorpagefaults,$minorpagefaults,$voluntarycontextswitches,$involuntarycontextswitches,$swaps,$filesysteminputs,$filesystemoutputs,$socketmessagessent,$socketmessagesreceived,$signalsdelivered,$pagesize" > .csvLine
cat .csvLine
rm .csvLine
