#!/bin/bash


	echo -n "16" > /sys/class/gpio/export 
	echo -n "22" > /sys/class/gpio/export 
	echo -n "out" > /sys/class/gpio/gpio16/direction
	echo -n "in" > /sys/class/gpio/gpio22/direction
while :
do 
	var=$(cat /sys/class/gpio/gpio22/value)
	if [ $var -eq "1" ]
	then
		for (( i=1; i <= 5; i++ ))
		do
			echo -n "1" > /sys/class/gpio/gpio16/value
			sleep 2
			echo "Led Start"
			echo -n "0" > /sys/class/gpio/gpio16/value
			sleep 2
			echo "Led Off"
		done
	fi
done
