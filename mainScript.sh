#modprobe -r tcp_probe
sudo modprobe tcp_probe port=5201 
sudo chmod 444 /proc/net/tcpprobe

sysctl -w net.ipv4.tcp_no_metrics_save=1
sysctl -w net.ipv4.tcp_wmem='4096 16384 10000000'
sysctl -w net.ipv4.tcp_rmem='4096 87380 10000000'

for delay in 100 200
do
    tc qdisc add dev lo root netem delay ${delay}ms
    sudo bash caTestTemplate.sh delay_${delay}
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
