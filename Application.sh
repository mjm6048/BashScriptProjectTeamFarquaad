#! /usr/bin/env bash

# if [ ! -d "./Output" ]; then
#     echo "Hi"
#     mkdir Output
# fi

function cleanUpOutput(){
if [ ! -d "./Output" ]; then
    mkdir Output
else
    rm -r Output
    mkdir Output
fi
}

function ProcessMetrics(){
    ps -e -o comm,%cpu,%mem | grep -v "0.0  0.0" | while read -r comm cpu mem
    do
        if [ ! -f "./Output/${comm}_metrics.csv" ]; then  
            echo "seconds,%CPU,%memory" > ./Output/${comm}_metrics.csv
            echo "$1,$cpu,$mem" >> ./Output/${comm}_metric.csv
        else 
            echo "$1,$cpu,$mem" >> ./Output/${comm}_metrics.csv
        fi
    done
}

function SystemMetrics(){
    read -r rx tx <<< $(ifstat | grep "ens" | tr -s ' ' | cut -d " " -f 6,8)
    diskwrites=$(iostat | grep "sda" | tr -s ' ' | cut -d " " -f 4)
    diskcapacity=$(df -m / | grep "rl-root" | tr -s ' ' | cut -d " " -f 4) 
    echo "$1,$rx,$tx,$diskwrites,$diskcapacity" >> ./Output/system_metrics.csv
}



endTime=$(($1*60))
timer=0
cleanUpOutput
echo "seconds,rx data rate,tx data rate,disk writes,available disk capacity" > ./Output/system_metrics.csv
while [ $timer -lt $endTime ]
do  
    ProcessMetrics $timer
    SystemMetrics $timer
    timer=$(($timer + 5))
    sleep 5s
done

echo "Ran for $timer Seconds"