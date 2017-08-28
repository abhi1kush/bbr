#modprobe -r tcp_probe
sudo modprobe tcp_probe port=5201 full=1
sudo chmod 444 /proc/net/tcpprobe

sysctl -w net.ipv4.tcp_no_metrics_save=1
sysctl -w net.ipv4.tcp_wmem='4096 16384 10000000'
sysctl -w net.ipv4.tcp_rmem='4096 87380 10000000'

t=10

for delay in 100 200
do
    testname=delay_${delay}
    tc qdisc add dev lo root netem delay ${delay}ms
    echo "----------------- Running Test delay_${delay} ------------------" 

    # duration of test in seconds
    # pass this to iperf

    # for each congestion algo
    for c in bbr cubic reno 
    do
        echo "running algo $c for $t seconds"
        # construct name for output files
        o=${c}_${testname}
        
        #set congestion control algo
        echo "setting congestion control algo $c"
        sysctl -w net.ipv4.tcp_congestion_control=$c
        
        # collect packet level stats using tcpprobe 
        #sudo cat /proc/net/tcpprobe > "$o.prb" &
        #TCPCAP=$!
        
        #runing iperf3 for $t seconds, and redirect the output to disk
        echo "running iperf3 for $t seconds, and redirected the output to $o"
        iperf3 -t $t -c 127.0.0.1 > "${o}.out" 2>> error
        
        # capture iperf exit status
        s=$?

        # Stop recording from tcp
        #kill $TCPCAP
        wait
        
        # Make sure iperf returned without errors
        if [ $s -ne 0 ]; then
            echo iperf3 returned errors
            #rm $o.prb 2> error
            #rm $o.ipf 2>> error
            exit 1
        fi

        #retain sending side packets only. This assumes use of the default port 5201.
        grep -v "127.0.0.1:5201 127.0.0.1" $o.prb > $o.tmp 2> error
        mv $o.tmp $o.prb 2> error
    done
    tc qdisc del dev lo root netem
done

#for loss in 0.1 1 10 15
#do
#    tc qdisc add dev lo root netem delay 100ms loss ${loss}%
#    caTestTemplate.sh delay_100_loss_${loss}
#    tc qdisc del dev lo root netem 
#done
#
#tc qdisc add dev lo root handle 1: netem delay 100ms loss 0.1%
#tc qdisc add dev lo parent 1: tbf rate 512kbit buffer 10k latency 10ms
#caTestTemplate.sh tbf_512kbit
#tc qdisc del dev lo root netem 
#
