#! /usr/bin/env bash

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

function spawnProcesses(){
    ipAddress=172.16.1.37
    echo "Spawning processes"
    ./Processes/bandwidth_hog "$ipAddress"

    ./Processes/bandwidth_hog_burst "$ipAddress"

    ./Processes/cpu_hog "$ipAddress"

    ./Processes/disk_hog "$ipAddress"

    ./Processes/memory_hog "$ipAddress"

    ./Processes/memory_hog_leak "$ipAddress"
}

function cleanup(){
    trap spawnProcesses EXIT
    echo "Performing cleanup"
}

endTime=$(($1*60))
timer=0
cleanUpOutput
echo "seconds,rx data rate,tx data rate,disk writes,available disk capacity" > ./Output/system_metrics.csv
cleanup
while [ $timer -lt $endTime ]
do  
    ProcessMetrics $timer
    SystemMetrics $timer
    timer=$(($timer + 5))
    sleep 5s
done

echo "Ran for $timer Seconds"