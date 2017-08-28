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

echo "----------------- Running Test $1 ------------------" 

# duration of test in seconds
# pass this to iperf
t=10

# for each congestion algo
for c in bbr cubic reno 
do
	echo "running algo $c for $t seconds"
	# construct name for output files
	o=${c}_${1}
	
	#set congestion control algo
	echo "setting congestion control algo $c"
	sysctl -w net.ipv4.tcp_congestion_control=$c
    
    # collect packet level stats using tcpprobe 
    #sudo cat /proc/net/tcpprobe > "$o.prb" &
    #TCPCAP=$!
	
	#runing iperf3 for $t seconds, and redirect the output to disk
	echo "running iperf3 for $t seconds, and redirected the output to $o"
    iperf3 -t $t -c 127.0.0.1 -Z > "${o}.out" 2>> error
	
	# capture iperf exit status
	s=$?

	# Stop recording from tcp
	#kill $TCPCAP
	#wait
	
	# Make sure iperf returned without errors
	if [ $s -ne 0 ]; then
        echo iperf3 returned errors
	    rm $o.prb 2> error
	    #rm $o.ipf 2>> error
	    exit 1
	fi

	#retain sending side packets only. This assumes use of the default port 5201.
	grep -v "127.0.0.1:5201 127.0.0.1" $o.prb > $o.tmp 2> error
	mv $o.tmp $o.prb 2> error
done
