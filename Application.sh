#! /usr/bin/env bash

if [ ! -d "./Output" ]; then
    echo "Hi"
    mkdir Output
fi

function ProcessMetrics(){
    ps -e -o comm,%cpu,%mem | grep -v "0.0  0.0" | while read -r line comm cpu mem
    do
        if [ ! -f "./Output/$comm.csv" ]; then  
            "Process,%CPU,%MEM" > ./Output/$comm.csv
            echo $line >> ./Output/$comm.csv
        else 
            echo $line >> ./Output/$comm.csv

        fi
    done

}


endTime=$(($1*60))
timer=0
while [ $timer -lt $endTime ]
do  
    ProcessMetrics $timer
    timer=$(($timer + 5))
    sleep 5s
done

echo $timer