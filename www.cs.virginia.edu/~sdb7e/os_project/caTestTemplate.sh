#!/bin/sh

# Execute a series of TCP tests using different congestion algorithms.
# The first command line argument will form the file name suffix used 
# to identify the test run.
# A receiving instance of iperf -s should be running prior to starting
# this script. This script should be run as root.

if [ $# -ne 1 ]; then
	echo "Usage: caTest testName" 
	exit 1
fi

echo "\n*** running test $1 ***\n" 

# duration of test in seconds
# pass this to iperf
t=60

# for each congestion algo
for c in reno cubic htcp veno
do
	echo "running algo $c for $t seconds"
	# construct name for output files
	o=$c$1
	
	# TODO: set congestion control algo
	echo "TODO: set congestion control algo"
	
	# collect packet level stats using tcpprobe
	cat /proc/net/tcpprobe >"$o.prb" &
	p=$!
	
	# TODO: run iperf for $t seconds, and redirect the output to disk
	echo "TODO: run iperf for $t seconds, and redirect the output to disk"
	
	# capture iperf exit status
	s=$?
	# Stop recording from tcp
	kill $p
	wait
	
	# Make sure iperf returned without errors
	if [ $s -ne 0 ]; then
	    rm $o.prb
	    rm $o.ipf
	    exit 1
	fi

	# retain sending side packets only. This assumes use of the default port 5001.
	grep -v "127.0.0.1:5001 127.0.0.1" $o.prb > $o.tmp
	mv $o.tmp $o.prb
done



