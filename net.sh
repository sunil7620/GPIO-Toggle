#!/bin/bash

#----------------------------------------------------------|
#title           :cloud.sh                                 |
#description     :This script is used for to enable IoT    |
#author		 :Sunil                                    |
#date            :20181025                                 |
#version         :0.1                                      |
#usage		 :./cloud.sh				   |	
#==========================================================|

#----------------------------------------------------------|
#********************GPIO MAPPING**************************|
#----------------------------------------------------------|
#**|GPIO NUMBER**|**GPIO FUNCITON**************************|
#**|GPIO21       |Assigned for Network Connectivity********|
#**|GPIO16       |Assigned for BULB1***********************|
#**|GPIO20       |Assigned for BULB2***********************|
#**|GPIO22       |Assigned for Switch to Enable Camera*****|
#**|GPIO23       |Assigned for PIR*************************|
#**|GPIO24       |Assigned for BUZZER**********************|
#----------------------------------------------------------|
#file="/home/sunil/wifi.sh"

#Checking Internet Connectivity
sudo killall mosquitto_sub
if [  -f  /sys/clas/gpio/gpio20/value ]
then
	echo "GPIO Exported"
else
	echo "GPIO Exporting........"

echo "18" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio18/direction

echo "20" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio20/direction
echo "1" > /sys/class/gpio/gpio20/value



echo "24" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio24/direction
echo "1" > /sys/class/gpio/gpio24/value


echo "16" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio16/direction
echo "1" > /sys/class/gpio/gpio16/value


echo "21" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio21/direction
echo "1" > /sys/class/gpio/gpio21/value


echo "17" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio17/direction
echo "1" > /sys/class/gpio/gpio17/value


echo "27" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio27/direction
echo "1" > /sys/class/gpio/gpio27/value


echo "22" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio22/direction
echo "1" > /sys/class/gpio/gpio22/value

fi

network()
{
	if ping -q -c 2 -W 5 8.8.8.8 >/dev/null; then
		echo "Network Detected"
		echo -n "0" > /sys/class/gpio/gpio27/value
		sleep 1
	else
		echo "Network not detected"
		echo -n "0" > /sys/class/gpio/gpio27/value
	fi
}

mosquitto_sub -h  13.235.95.137  -t "BULB1" >  BULB1.txt &
mosquitto_sub -h  13.235.95.137  -t "BULB2" >  BULB2.txt &
mosquitto_sub -h  13.235.95.137  -t  "CAM" >    CAM.txt &
mosquitto_sub -h  13.235.95.137  -t "Buzzer" > buzzer.txt &
while :
do
network
var=$(tail -n 1 BULB1.txt)
if [ "$var" == "1" ]; then
	echo "Bulb1 ON"
	echo "0" > /sys/class/gpio/gpio16/value
elif [ "$var" == "0" ]; then
	echo "Bulb1 OFF"
	echo "1" > /sys/class/gpio/gpio16/value
fi


var1=$(tail -n 1 BULB2.txt)
if [ "$var1" == "1" ]; then
	echo "Bulb2 ON"
	echo "0" > /sys/class/gpio/gpio20/value
elif [ "$var" == "0" ]; then
	echo "Bulb2 OFF"
	echo "1" > /sys/class/gpio/gpio20/value
fi

var3=$(tail -n 1 buzzer.txt)
if [ "$var3" == "1" ]; then
	echo "Buzzer ON"
	echo "0" > /sys/class/gpio/gpio24/value
elif [ "$var3" == "0" ]; then
	echo "Buzzer OFF"
	echo "1" > /sys/class/gpio/gpio24/value
fi

pir=$(cat /sys/class/gpio/gpio18/value)
echo $pir
if [ "$pir" == "1" ]; then
	echo "Intrusion Detected"
 	mosquitto_pub -h 13.235.95.137  -t "PIR" -m "Detected" 
	echo "0" > /sys/class/gpio/gpio24/value
echo "Test"
elif [ "$pir" == "0" ]; then
 	mosquitto_pub -h 13.235.95.137  -t "PIR" -m "Not Detected" 
fi

done
